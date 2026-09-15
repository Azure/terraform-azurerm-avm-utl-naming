#requires -Version 7.4

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot '..\ResourceNameRules.psm1') -Force
Import-Module (Join-Path $PSScriptRoot '..\ResourceNameCatalog.psm1') -Force
Import-Module (Join-Path $PSScriptRoot '..\ResourceNameRules.Automation.psm1') -Force
$script:Passed = 0

function Assert-True {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Exception {
    param([scriptblock] $Action, [string] $Pattern)
    try { & $Action }
    catch {
        if ($_.Exception.Message -notmatch $Pattern) { throw }
        return
    }
    throw "Expected an error matching '$Pattern'."
}

function Test-Case {
    param([string] $Name, [scriptblock] $Body)
    & $Body
    $script:Passed++
    Write-Output "PASS $Name"
}

function Get-RulesDocument {
    param([string] $Extra = '')
    return @"
# Naming rules and restrictions for Azure resources

## Microsoft.Storage
| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| storageAccounts | global | 3-24 | Lowercase letters and numbers |

## Microsoft.Web
| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| sites | global | 2-60 | Alphanumerics and hyphens. Start and end with alphanumeric. |

## Microsoft.Foo
| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| servers | parent | 1-20 | Alphanumerics |

## Microsoft.Bar
| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| servers | parent | 1-20 | Alphanumerics |

$Extra

## Next steps
[Naming](https://example.test/naming-and-tagging)
[Reserved names](error-reserved-resource-name.md)
"@
}

$script:Abbreviations = @'
# Abbreviation recommendations for Azure resources

## Examples
| Resource | Resource provider namespace | Abbreviation |
|--|--|--|
| Storage account | `Microsoft.Storage/storageAccounts` | `st` |
| VM storage account | `Microsoft.Storage/storageAccounts` | `stvm` |
| Web app | `Microsoft.Web/sites` | `app` |
| Function app | `Microsoft.Web/sites` | `func` |

## Next step
[Tags](./resource-tagging.md)
'@
$script:Rules = Get-RulesDocument
$script:Manual = [ordered]@{
    schema_version = 2
    legacy_mappings = [ordered]@{
        storage_account = @{ resource_type = 'Microsoft.Storage/storageAccounts'; variant = $null; slug = 'legacy' }
        app_service = @{ resource_type = 'Microsoft.Web/sites'; variant = 'web_app'; slug = 'app' }
        function_app = @{ resource_type = 'Microsoft.Web/sites'; variant = 'function_app'; slug = 'func' }
    }
    resources = [ordered]@{}
}

function Get-TestCatalog {
    return ConvertTo-ResourceNameCatalog -RulesMarkdown $script:Rules -AbbreviationsMarkdown $script:Abbreviations -Manual $script:Manual
}

function Invoke-MockedPublication {
    param(
        [string] $Root,
        [string] $Document,
        [string] $Failure = ''
    )

    $catalog = Get-TestCatalog
    $null = Write-NamingCatalog $catalog.Generated (Join-Path $Root 'data\resource-name-rules.json') -Confirm:$false
    $null = Write-NamingCatalog $catalog.Manual (Join-Path $Root 'data\resource-name-rules.manual.json') -Confirm:$false
    $state = @{
        calls = [System.Collections.Generic.List[string]]::new()
        failure = $Failure
        validated = $false
        changed = $Document -cne $script:Rules
    }
    $expectedRoot = $Root
    $runner = {
        param($FileName, $Arguments, $Directory)
        if ($Directory -cne $expectedRoot) { throw 'Unexpected working directory.' }
        $index = 0
        while ($Arguments[$index] -eq '-c') { $index += 2 }
        $operation = "$FileName.$($Arguments[$index])"
        $state.calls.Add($operation)
        if ($state.failure -eq $operation) {
            return [pscustomobject]@{ ExitCode = 1; StdOut = ''; StdErr = 'Simulated failure.' }
        }
        $stdout = ''
        $exitCode = 0
        switch ($operation) {
            'git.status' {}
            'git.remote' { $stdout = 'https://github.com/Azure/terraform-azure-avm-utl-naming.git' }
            'git.check-ref-format' {}
            'git.fetch' {}
            'git.ls-remote' { $exitCode = 2 }
            'git.checkout' {}
            'git.diff' { if ($state.changed) { $stdout = 'data/resource-name-rules.json' } }
            'git.add' {}
            'git.commit' {
                if (-not $state.validated) { throw 'Commit occurred before validation.' }
            }
            'git.push' {
                if (-not $state.validated) { throw 'Push occurred before validation.' }
                if (-not ($Arguments -match '^--force-with-lease=')) { throw 'Push has no concurrency guard.' }
            }
            'gh.api' {
                if ($Arguments -contains 'GET') { $stdout = '[]' }
                else { $stdout = '{"fork":false,"full_name":"Azure/terraform-azure-avm-utl-naming","default_branch":"main"}' }
            }
            'gh.pr' { $stdout = 'https://github.com/Azure/terraform-azure-avm-utl-naming/pull/123' }
            default { throw "Unmocked operation: $operation" }
        }
        return [pscustomobject]@{ ExitCode = $exitCode; StdOut = $stdout; StdErr = '' }
    }.GetNewClosure()
    $validation = {
        if ($state.failure -eq 'validation') { throw 'Simulated validation failure.' }
        $state.validated = $true
    }.GetNewClosure()
    $result = Publish-ResourceNameRulesUpdate -Repository 'Azure/terraform-azure-avm-utl-naming' -BaseBranch main -RepositoryRoot $Root -Markdown $Document -AbbreviationsMarkdown $script:Abbreviations -CommandRunner $runner -ValidationRunner $validation
    return [pscustomobject]@{ Result = $result; State = $state }
}

Test-Case 'snake-case keys are generated from hierarchy and plural nouns' {
    Assert-True ((ConvertTo-NamingTerraformKey 'Microsoft.Storage/storageAccounts') -ceq 'storage_account') 'Incorrect storage key.'
    Assert-True ((ConvertTo-NamingTerraformKey 'Microsoft.Kusto/clusters/databases') -ceq 'cluster_database') 'Incorrect child key.'
    Assert-True ((ConvertTo-NamingTerraformKey 'Microsoft.KeyVault/managedHSMs') -ceq 'managed_hsm') 'Incorrect acronym key.'
}

Test-Case 'only colliding keys receive provider prefixes' {
    $catalog = Get-TestCatalog
    Assert-True ($catalog.Generated.resources.Contains('storage_account')) 'A unique key was renamed.'
    Assert-True ($catalog.Generated.resources.Contains('foo_server') -and $catalog.Generated.resources.Contains('bar_server')) 'Collisions were not qualified.'
}

Test-Case 'same-type variants are distinct JSON entries' {
    $catalog = Get-TestCatalog
    $web = $catalog.Generated.resources.site_web_app
    $function = $catalog.Generated.resources.site_function_app
    Assert-True ($web.resource_type -ceq $function.resource_type) 'Variants invented different Azure types.'
    Assert-True ($web.legacy_slug -ceq 'app' -and $function.legacy_slug -ceq 'func') 'Legacy variant slugs changed.'
    Assert-True ($web.legacy_outputs -contains 'app_service' -and $function.legacy_outputs -contains 'function_app') 'Legacy aliases were lost.'
}

Test-Case 'explicit variants are not collapsed by a shared abbreviation' {
    $manual = $script:Manual | ConvertTo-Json -Depth 20 | ConvertFrom-Json -AsHashtable
    $manual.legacy_mappings.storage_special = @{
        resource_type = 'Microsoft.Storage/storageAccounts'
        variant = 'special'
        slug = 'st'
        separate_variant = $true
    }
    $catalog = ConvertTo-ResourceNameCatalog -RulesMarkdown $script:Rules -AbbreviationsMarkdown $script:Abbreviations -Manual $manual
    Assert-True ($catalog.Generated.resources.Contains('storage_account_special')) 'The explicit variant was folded into the generic entry.'
    Assert-True ($catalog.Generated.resources.storage_account_special.legacy_outputs -contains 'storage_special') 'The variant lost its compatibility mapping.'
    Assert-True ($catalog.Generated.resources.storage_account.legacy_outputs -notcontains 'storage_special') 'The generic entry captured the explicit variant.'
}

Test-Case 'current and legacy slugs remain independent' {
    $catalog = Get-TestCatalog
    $storage = $catalog.Generated.resources.storage_account
    Assert-True ($storage.slug -ceq 'st' -and $storage.slug_source -ceq 'caf') 'The documented abbreviation was not selected.'
    Assert-True ($storage.legacy_slug -ceq 'legacy') 'The old slug was not retained independently.'
    Assert-True ($catalog.Generated.resources.foo_server.slug_source -ceq 'derived') 'A derived slug was presented as a documented abbreviation.'
}

Test-Case 'simple bounds and character constraints are translated' {
    $record = (Get-TestCatalog).Generated.resources.storage_account
    Assert-True ($record.min_length -eq 3 -and $record.max_length -eq 24) 'Numeric bounds changed.'
    Assert-True ($record.validation_complete -and $record.lowercase -and -not $record.dashes) 'A simple rule was not correctly translated.'
    Assert-True ('abc123' -cmatch $record.regex -and 'ABC' -cnotmatch $record.regex) 'The generated character class is incorrect.'
}

Test-Case 'mixed-case alphanumerics retain distinct uppercase and lowercase ranges' {
    $record = ConvertTo-NamingRuntimeRule -Rule @{
        resource_type = 'Microsoft.Test/names'; scope = 'parent'; length = '1-30'
        valid_characters = 'Alphanumerics and hyphens. Start and end with alphanumeric.'
    }
    Assert-True ('Contoso-Test' -cmatch $record.regex -and 'contoso-test' -cmatch $record.regex) 'Uppercase letters were lost during character-class compression.'
    Assert-True (-not $record.lowercase -and $record.dashes) 'Mixed-case separator policy changed.'
}

Test-Case 'comma-separated lowercase rules retain documented hyphens' {
    $record = ConvertTo-NamingRuntimeRule -Rule @{
        resource_type = 'Microsoft.Test/names'; scope = 'parent'; length = '3-40'
        valid_characters = "Lowercase letters, numbers, and hyphens. Can't start or end with hyphen."
    }
    Assert-True ($record.dashes -and $record.lowercase) 'Documented hyphens were silently disabled.'
    Assert-True ($record.forbidden_prefixes -contains '-' -and $record.forbidden_suffixes -contains '-') 'Hyphen boundary restrictions were lost.'
}

Test-Case 'character lists are independent of word ordering' {
    $rules = @(
        "Lowercase letters, numbers, and hyphens. Can't start or end with hyphen.",
        "Lowercase letters, hyphens, and numbers. Can't start or end with hyphen."
    )
    $records = @($rules | ForEach-Object {
        ConvertTo-NamingRuntimeRule -Rule @{
            resource_type = 'Microsoft.Test/names'; scope = 'parent'; length = '3-40'; valid_characters = $_
        }
    })
    Assert-True ($records[0].regex -ceq $records[1].regex -and $records[1].dashes -and $records[1].validation_complete) 'Equivalent character lists produced different rules.'
    Assert-True ('abc-123' -cmatch $records[1].regex -and '-abc' -cnotmatch $records[1].regex -and 'abc-' -cnotmatch $records[1].regex) 'Published regex omitted the documented hyphen boundaries.'
}

Test-Case 'letter-only rules do not implicitly allow digits' {
    $record = ConvertTo-NamingRuntimeRule -Rule @{
        resource_type = 'Microsoft.Test/names'; scope = 'parent'; length = '1-40'
        valid_characters = 'Lowercase letters and hyphens.'
    }
    Assert-True ('abc-def' -cmatch $record.regex -and 'abc123' -cnotmatch $record.regex) 'Digits were added to a letter-only rule.'
}

Test-Case 'start and end classes are reflected in explicit boundary metadata' {
    $record = ConvertTo-NamingRuntimeRule -Rule @{
        resource_type = 'Microsoft.Test/names'; scope = 'parent'; length = '1-40'
        valid_characters = 'Alphanumerics and hyphens. Start and end with alphanumeric.'
    }
    Assert-True ($record.forbidden_prefixes -contains '-' -and $record.forbidden_suffixes -contains '-') 'Regex boundaries and truncation metadata disagree.'
}

Test-Case 'unknown rules remain explicit rather than permissive success' {
    $record = ConvertTo-NamingRuntimeRule -Rule $null
    Assert-True ($null -eq $record.regex -and $null -eq $record.max_length -and -not $record.validation_complete) 'Unknown constraints were invented.'
    Assert-True ($record.validation_notes.Count -gt 0) 'Unknown validation has no explanation.'
}

Test-Case 'GUID and literal naming modes are recognized' {
    $guid = ConvertTo-NamingRuntimeRule -Rule @{ resource_type = 'Microsoft.Test/guids'; scope = 'parent'; length = '36'; valid_characters = 'Must be a globally unique identifier (GUID).' }
    $literal = ConvertTo-NamingRuntimeRule -Rule @{ resource_type = 'Microsoft.Test/literals'; scope = 'parent'; length = '1-20'; valid_characters = 'Use default.' }
    Assert-True ($guid.name_kind -eq 'uuid' -and $guid.min_length -eq 36) 'GUID mode was not recognized.'
    Assert-True ($literal.name_kind -eq 'literal' -and $literal.fixed_name -ceq 'default') 'Literal mode was not recognized.'
}

Test-Case 'source errors are corrected without creating fake duplicate types' {
    Assert-True ((Resolve-NamingResourceType 'Microsoft.Network/dnsForwardingRuleset') -ceq 'Microsoft.Network/dnsForwardingRulesets') 'DNS type correction failed.'
    Assert-True ((Resolve-NamingResourceType 'Microsoft.Databricks/workspaces/accessConnectors') -ceq 'Microsoft.Databricks/accessConnectors') 'Databricks type correction failed.'
    Assert-True ((Resolve-NamingResourceType 'Microsoft.Network/vpnGateways/vpnSites') -ceq 'Microsoft.Network/vpnSites') 'VPN site type correction failed.'
}

Test-Case 'malformed source documents fail before generation' {
    Assert-Exception { ConvertFrom-ResourceNameRulesMarkdown '# An error page' } 'Incomplete|expected'
    Assert-Exception { ConvertFrom-ResourceAbbreviationsMarkdown '# An error page' } 'Incomplete|unexpected'
    Assert-Exception { ConvertFrom-ResourceNameRulesMarkdown ($script:Rules.Replace('storageAccounts | global', 'storageAccounts | extra | global')) } 'four'
}

Test-Case 'duplicate source identities are rejected' {
    $duplicate = $script:Rules.Replace('| storageAccounts | global | 3-24 | Lowercase letters and numbers |', "| storageAccounts | global | 3-24 | Lowercase letters and numbers |`n| storageAccounts | global | 3-24 | Lowercase letters and numbers |")
    Assert-Exception { ConvertFrom-ResourceNameRulesMarkdown $duplicate } 'Duplicate'
}

Test-Case 'JSON duplicate properties and invalid schemas are rejected' {
    Assert-Exception { ConvertFrom-NamingCatalogJson '{"schema_version":2,"resources":{},"resources":{}}' } 'Duplicate'
    Assert-Exception { ConvertFrom-NamingCatalogJson '{"schema_version":1,"resources":{}}' } 'schema-v2'
}

Test-Case 'repeated generation produces identical bytes' {
    $first = ConvertTo-NamingCatalogJson (Get-TestCatalog).Generated
    $second = ConvertTo-NamingCatalogJson (Get-TestCatalog).Generated
    Assert-True ($first -ceq $second) 'Generation was not deterministic.'
}

Test-Case 'new collisions do not rename existing keys or derived slugs' {
    $firstExtra = @'
## Microsoft.First
| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| widgets | parent | 1-40 | Alphanumerics |
'@
    $secondExtra = @'
## Microsoft.Second
| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| widgets | parent | 1-40 | Alphanumerics |
'@
    $initial = ConvertTo-ResourceNameCatalog -RulesMarkdown (Get-RulesDocument $firstExtra) -AbbreviationsMarkdown $script:Abbreviations -Manual $script:Manual
    $updated = ConvertTo-ResourceNameCatalog -RulesMarkdown (Get-RulesDocument ($firstExtra + "`n" + $secondExtra)) -AbbreviationsMarkdown $script:Abbreviations -Manual $initial.Manual -Previous $initial.Generated
    Assert-True ($updated.Generated.resources.Contains('widget') -and $updated.Generated.resources.Contains('second_widget')) 'The established key was renamed instead of qualifying the new collision.'
    Assert-True ($updated.Generated.resources.widget.slug -ceq $initial.Generated.resources.widget.slug) 'The established derived slug changed.'
    $rebuilt = ConvertTo-ResourceNameCatalog -RulesMarkdown (Get-RulesDocument ($firstExtra + "`n" + $secondExtra)) -AbbreviationsMarkdown $script:Abbreviations -Manual $updated.Manual
    Assert-True ((ConvertTo-NamingCatalogJson $rebuilt.Generated) -ceq (ConvertTo-NamingCatalogJson $updated.Generated)) 'Persisted assignments did not reproduce the same keys without the previous generated file.'
}

Test-Case 'manual settings overrides remain separate and are validated' {
    $manual = [ordered]@{
        schema_version = 2
        resources = [ordered]@{}
        legacy_mappings = $script:Manual.legacy_mappings
        overrides = [ordered]@{
            storage_account = @{
                settings = @{ max_length = 20 }
                reason = 'Reviewed naming limit.'
                source = 'https://example.test/reviewed-rule'
            }
        }
    }
    $result = ConvertTo-ResourceNameCatalog -RulesMarkdown $script:Rules -AbbreviationsMarkdown $script:Abbreviations -Manual $manual
    Assert-True ($result.Generated.resources.storage_account.max_length -eq 24 -and $result.Manual.overrides.storage_account.settings.max_length -eq 20) 'A manual patch overwrote the generated source data.'
    $manual.overrides.storage_account.settings = @{ resource_type = 'Microsoft.Other/types' }
    Assert-Exception { ConvertFrom-NamingCatalogJson (ConvertTo-NamingCatalogJson $manual) } 'identity|unsupported'
}

Test-Case 'promotions remove documented types from manual resources' {
    $initial = Get-TestCatalog
    $manual = [ordered]@{ schema_version = 2; legacy_mappings = $script:Manual.legacy_mappings; resources = [ordered]@{ storage_account = $initial.Generated.resources.storage_account } }
    $result = ConvertTo-ResourceNameCatalog -RulesMarkdown $script:Rules -AbbreviationsMarkdown $script:Abbreviations -Manual $manual
    Assert-True ($result.Manual.resources.Count -eq 0 -and $result.Generated.resources.Contains('storage_account')) 'A documented type remained manually defined.'
}

Test-Case 'types removed from selected sources become explicit manual fallback' {
    $initial = Get-TestCatalog
    $changed = ($script:Rules -replace "`r`n?", "`n").Replace("## Microsoft.Foo`n| Entity | Scope | Length | Valid Characters |`n| --- | --- | --- | --- |`n| servers | parent | 1-20 | Alphanumerics |`n", '')
    $result = ConvertTo-ResourceNameCatalog -RulesMarkdown $changed -AbbreviationsMarkdown $script:Abbreviations -Manual $script:Manual -Previous $initial.Generated
    Assert-True ($result.Manual.resources.Contains('foo_server')) 'A formerly documented type was dropped.'
    Assert-True ($result.Manual.resources.foo_server.source.status -eq 'removed_from_selected_sources') 'Fallback provenance was not recorded.'
}

$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) "avm-naming-catalog-tests-$([guid]::NewGuid().ToString('N'))"
$null = New-Item -ItemType Directory -Path (Join-Path $testRoot 'data') -Force
try {
    Test-Case 'file updates are byte-stable on a no-op refresh' {
        $catalog = Get-TestCatalog
        $generatedPath = Join-Path $testRoot 'data\resource-name-rules.json'
        $manualPath = Join-Path $testRoot 'data\resource-name-rules.manual.json'
        $null = Write-NamingCatalog $catalog.Generated $generatedPath -Confirm:$false
        $null = Write-NamingCatalog $catalog.Manual $manualPath -Confirm:$false
        $before = (Get-FileHash -LiteralPath $generatedPath).Hash
        $update = Update-ResourceNameCatalog -RulesMarkdown $script:Rules -AbbreviationsMarkdown $script:Abbreviations -GeneratedPath $generatedPath -ManualPath $manualPath -Confirm:$false
        Assert-True (-not $update.Changed -and (Get-FileHash -LiteralPath $generatedPath).Hash -eq $before) 'A no-op refresh rewrote data.'
    }

    Test-Case 'publication defers an existing review without changing files' {
        $state = @{ calls = [System.Collections.Generic.List[string]]::new() }
        $expectedDirectory = $testRoot
        $runner = {
            param($FileName, $Arguments, $Directory)
            if ($Directory -cne $expectedDirectory) { throw 'Unexpected publication working directory.' }
            $command = "$FileName $($Arguments -join ' ')"
            $state.calls.Add($command)
            $stdout = switch -Regex ($command) {
                '^git status ' { ''; break }
                '^git remote get-url origin$' { 'https://github.com/Azure/terraform-azure-avm-utl-naming.git'; break }
                '^gh api repos/Azure/terraform-azure-avm-utl-naming$' { '{"fork":false,"full_name":"Azure/terraform-azure-avm-utl-naming","default_branch":"main"}'; break }
                '^gh api --method GET ' { '[{"number":123,"head":{"ref":"automation/resource-name-rules-additions","repo":{"full_name":"Azure/terraform-azure-avm-utl-naming"}},"base":{"ref":"main","repo":{"full_name":"Azure/terraform-azure-avm-utl-naming"}}}]'; break }
                default { throw "Unexpected mutation or command: $command" }
            }
            return [pscustomobject]@{ ExitCode = 0; StdOut = $stdout; StdErr = '' }
        }.GetNewClosure()
        $result = Publish-ResourceNameRulesUpdate -Repository 'Azure/terraform-azure-avm-utl-naming' -BaseBranch main -RepositoryRoot $testRoot -Markdown $script:Rules -AbbreviationsMarkdown $script:Abbreviations -CommandRunner $runner
        Assert-True ($result.Status -eq 'pending_review' -and -not $result.Pushed) 'An open review was overwritten.'
        Assert-True ($state.calls.Count -eq 4) 'Unexpected publication calls occurred.'
    }

    $extra = @'
## Microsoft.New
| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| widgets | parent | 1-40 | Alphanumerics |
'@
    $changedDocument = Get-RulesDocument $extra
    Test-Case 'a no-op publication does not commit or push' {
        $result = Invoke-MockedPublication -Root $testRoot -Document $script:Rules
        Assert-True ($result.Result.Status -eq 'unchanged' -and -not $result.Result.Pushed) 'No-op publication changed the branch.'
        Assert-True (-not $result.State.calls.Contains('git.commit') -and -not $result.State.calls.Contains('git.push')) 'No-op publication performed a write.'
    }

    Test-Case 'changed runtime data is validated before guarded publication' {
        $result = Invoke-MockedPublication -Root $testRoot -Document $changedDocument
        Assert-True ($result.Result.Status -eq 'proposed' -and $result.Result.Pushed -and $result.State.validated) 'Runtime data was not validated and proposed.'
    }

    Test-Case 'publication failures are not reported as no changes' {
        foreach ($failure in @('git.fetch', 'git.commit', 'git.push', 'gh.pr', 'validation')) {
            Assert-Exception { Invoke-MockedPublication -Root $testRoot -Document $changedDocument -Failure $failure } 'failed|failure'
        }
    }

    Test-Case 'fork publication is rejected before commands execute' {
        Assert-Exception {
            Publish-ResourceNameRulesUpdate -Repository 'someone/fork' -BaseBranch main -RepositoryRoot $testRoot -Markdown $script:Rules -AbbreviationsMarkdown $script:Abbreviations -CommandRunner { throw 'Must not execute.' }
        } 'upstream'
    }
}
finally {
    Remove-Item -LiteralPath $testRoot -Recurse -Force
}

Write-Output "Naming catalog tests: $script:Passed passed. Publication was mocked; no remote writes were made."
