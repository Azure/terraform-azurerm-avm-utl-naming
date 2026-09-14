#Requires -Version 7.4

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Import-Module Avm.Authoring -ErrorAction Stop
$terraform = (avm tool which terraform --passthru).Path
if (-not $terraform) {
    throw 'Run avm test unit first to install the managed Terraform executable.'
}

$moduleRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$revision = 'fc289126c9c888393ff02a79e1babadd6865861c'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) "avm-naming-upgrade-$([guid]::NewGuid().ToString('N'))"
$null = New-Item -ItemType Directory -Path $testRoot
$legacyRoot = Join-Path $testRoot 'legacy'
$null = New-Item -ItemType Directory -Path $legacyRoot
$logPath = Join-Path $testRoot 'terraform.log'

function Invoke-TestTerraform {
    param(
        [Parameter(Mandatory)]
        [string[]] $Arguments
    )

    $PSNativeCommandUseErrorActionPreference = $false
    & $terraform "-chdir=$testRoot" @Arguments *> $logPath
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        $detail = Get-Content -LiteralPath $logPath -Raw
        throw "Terraform $($Arguments[0]) failed with exit code $exitCode.`n$detail"
    }
}

function Get-TestTerraformJson {
    param([Parameter(Mandatory)][string[]] $Arguments)

    $PSNativeCommandUseErrorActionPreference = $false
    $json = & $terraform "-chdir=$testRoot" @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform $($Arguments[0]) failed."
    }
    return ($json -join "`n") | ConvertFrom-Json -AsHashtable -Depth 100
}

function Set-TestModuleSource {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string] $Source)

    $configuration = @{
        terraform = @{
            required_version = '>= 1.9, < 2.0'
            required_providers = @{
                random = @{
                    source = 'hashicorp/random'
                    version = '>= 3.3.2, < 4.0'
                }
            }
        }
        module = @{
            naming = @{
                source = $Source
                prefix = @('example')
                suffix = @('dev')
            }
        }
        output = @{
            naming = @{
                value = '${module.naming}'
            }
        }
    }
    $json = ConvertTo-Json -InputObject $configuration -Depth 10
    $configurationPath = Join-Path $testRoot 'main.tf.json'
    if ($PSCmdlet.ShouldProcess($configurationPath, 'Write isolated Terraform test configuration')) {
        [System.IO.File]::WriteAllText($configurationPath, $json)
    }
}

function Assert-LegacyOutput {
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary] $Expected,
        [Parameter(Mandatory)][System.Collections.IDictionary] $Actual
    )

    foreach ($name in $Expected.Keys) {
        if (-not $Actual.Contains($name)) {
            throw "The candidate removed the legacy output '$name'."
        }
        $before = ConvertTo-Json -InputObject $Expected[$name] -Depth 100 -Compress
        $after = ConvertTo-Json -InputObject $Actual[$name] -Depth 100 -Compress
        if ($before -cne $after) {
            throw "The candidate changed the legacy output '$name'."
        }
    }
}

try {
    foreach ($file in @('main.tf', 'outputs.tf', 'variables.tf', 'LICENSE')) {
        Invoke-WebRequest `
            -Uri "https://raw.githubusercontent.com/Azure/terraform-azurerm-naming/$revision/$file" `
            -OutFile (Join-Path $legacyRoot $file) `
            -TimeoutSec 60
    }

    Set-TestModuleSource -Source './legacy'
    Invoke-TestTerraform -Arguments @('init', '-backend=false', '-input=false', '-no-color')
    Invoke-TestTerraform -Arguments @('apply', '-auto-approve', '-input=false', '-no-color')
    $legacy = Get-TestTerraformJson -Arguments @('output', '-json', 'naming')
    if ($legacy.Count -ne 300 -or $legacy['unique-seed'] -cnotmatch '^[a-z][a-z0-9]{60}$') {
        throw 'The pinned legacy module did not produce the expected interface and random seed.'
    }

    Set-TestModuleSource -Source $moduleRoot.Replace('\', '/')
    Invoke-TestTerraform -Arguments @('init', '-upgrade', '-backend=false', '-input=false', '-no-color')
    Invoke-TestTerraform -Arguments @('plan', '-input=false', '-no-color', '-out=upgrade.tfplan')
    $plan = Get-TestTerraformJson -Arguments @('show', '-json', 'upgrade.tfplan')
    $expectedAddresses = @(
        'module.naming.random_string.first_letter'
        'module.naming.random_string.main'
    )
    $actualAddresses = @($plan.resource_changes | ForEach-Object { $_.address } | Sort-Object)
    if (($actualAddresses -join ',') -cne ($expectedAddresses -join ',')) {
        throw 'The upgrade changed the random resource addresses or introduced additional resources.'
    }
    foreach ($change in $plan.resource_changes) {
        if (($change.change.actions -join ',') -cne 'no-op') {
            throw "The upgrade changes resource '$($change.address)': $($change.change.actions -join ', ')."
        }
    }
    Assert-LegacyOutput -Expected $legacy -Actual $plan.planned_values.outputs.naming.value

    Invoke-TestTerraform -Arguments @('apply', '-input=false', '-no-color', 'upgrade.tfplan')
    $candidate = Get-TestTerraformJson -Arguments @('output', '-json', 'naming')
    Assert-LegacyOutput -Expected $legacy -Actual $candidate
    Invoke-TestTerraform -Arguments @('plan', '-input=false', '-no-color', '-detailed-exitcode')
    Invoke-TestTerraform -Arguments @('destroy', '-auto-approve', '-input=false', '-no-color')

    Write-Output "Preserved all $($legacy.Count) legacy outputs and both random resources; the upgraded module is idempotent."
}
finally {
    Remove-Item -LiteralPath $testRoot -Recurse -Force
}
