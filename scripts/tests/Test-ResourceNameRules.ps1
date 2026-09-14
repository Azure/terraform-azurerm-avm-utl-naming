#requires -Version 7.4
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Fixture factories operate only in the repository-local per-run test directory; git/gh writes are mocked.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Private assertion and collection helpers are not exported cmdlets.')]
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$scriptsRoot = Split-Path $PSScriptRoot -Parent
$repositoryRoot = Split-Path $scriptsRoot -Parent
Import-Module (Join-Path $scriptsRoot 'ResourceNameRules.psm1') -Force
Import-Module (Join-Path $scriptsRoot 'ResourceNameRules.Automation.psm1') -Force

$script:Passed = 0
$script:Failed = 0
$script:RunRoot = Join-Path $PSScriptRoot ('.runs-' + [guid]::NewGuid().ToString('N'))
[void] [System.IO.Directory]::CreateDirectory($script:RunRoot)

function Assert-True {
    param([bool] $Condition, [string] $Message = 'Assertion failed.')
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param($Actual, $Expected)
    if ($Actual -cne $Expected) {
        throw "Expected '$Expected'; received '$Actual'."
    }
}

function Assert-Throws {
    param([scriptblock] $Body, [string] $MessagePattern = '.')
    $caught = $false
    try {
        $null = & $Body
    }
    catch {
        $caught = $true
        if ($_.Exception.Message -notmatch $MessagePattern) {
            throw "Unexpected error: $($_.Exception.Message)"
        }
    }
    if (-not $caught) {
        throw 'Expected a failure, but the operation succeeded.'
    }
}

function Test-Case {
    param([string] $Name, [scriptblock] $Body)
    try {
        & $Body
        $script:Passed++
        Write-Information "PASS $Name" -InformationAction Continue
    }
    catch {
        $script:Failed++
        Write-Information "FAIL $Name`: $($_.Exception.Message)" -InformationAction Continue
        Write-Information $_.ScriptStackTrace -InformationAction Continue
    }
}

function New-TestDirectory {
    $path = Join-Path $script:RunRoot ([guid]::NewGuid().ToString('N'))
    [void] [System.IO.Directory]::CreateDirectory($path)
    return $path
}

$script:Header = @'
---
title: Naming rules and restrictions for Azure resources
ms.topic: article
---

# Naming rules and restrictions for Azure resources
'@
$script:Footer = @'
## Next steps

- See [Naming conventions](/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging).
- See [Reserved resource names](../templates/error-reserved-resource-name.md).
'@
$script:BaseRows = @(
    '| widgets | resource group | 1-63 | Alphanumerics and hyphens. |'
    '| gadgets | global | 2-50 | Start with a letter. |'
)

function New-TestDocument {
    param([string[]] $Rows = $script:BaseRows)
    return $script:Header + "`n`n## Microsoft.Example`n`n" +
        "> [!div class=`"mx-tableFixed`"]`n> | Entity | Scope | Length | Valid Characters |`n> | --- | --- | --- | --- |`n" +
        ($Rows -join "`n") + "`n`n" + $script:Footer + "`n"
}

$script:RepresentativeDocument = $script:Header + "`n`n" + @'
## Microsoft.ApiManagement

> [!div class="mx-tableFixed"]
> | Entity | Scope | Length | Valid Characters |
> | --- | --- | --- | --- |
> | service / apis / operations / tags | operation | 1-80 | Alphanumerics and hyphens<br><br>Start with a letter. |
> | service | global | 1-50 | Alphanumerics and hyphens. |

## Microsoft.AppConfiguration

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| configurationStores\* | global | 5-50 | Alphanumerics and hyphens. |

## Microsoft.Kusto

Entity | Scope | Length | Valid Characters
:--- | ---: | :---: | ---
/clusters / databases | cluster | 1-260 | Alphanumerics, hyphens, spaces, and periods.

## Microsoft.Storage

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| storageAccounts / blobServices | storage account | | Must be `default`. |

## Microsoft.Test (preview)

> | Entity | Scope | Length | Valid Characters |
> | --- | --- | --- | --- |
> | widgets | resource group | 1-63 | Literal \|, `a|b`, ``a`|b``, <code>x|y</code>, and <span title="a|b">HTML</span>. |
> | widgets / children | widgets | 32-bit integer | &#124;<br/><br>Letters &amp; numbers. |

## Microsoft.FileShares

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| file share | global | 3-63 | Lowercase letters, numbers, and hyphens. |

'@ + "`n" + $script:Footer + "`n"

function New-TestInventory {
    param([string] $Markdown = (New-TestDocument), [string] $Directory = (New-TestDirectory))
    $path = Join-Path $Directory 'data' 'resource-name-rules.json'
    $null = Update-ResourceNameRulesInventory -Markdown $Markdown -InventoryPath $path -Initialize
    return $path
}

function Get-FileBytes {
    param([string] $Path)
    return [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($Path))
}

function New-TestResponse {
    param(
        [string] $Text = (New-TestDocument),
        [int] $Status = 200,
        [string] $MediaType = 'text/plain'
    )
    $response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode] $Status)
    $response.Content = [System.Net.Http.StringContent]::new($Text, [System.Text.Encoding]::UTF8, $MediaType)
    return $response
}

function New-PublicationContext {
    param([string] $RemoteJson)

    $root = New-TestDirectory
    $path = New-TestInventory -Directory $root
    $state = @{
        Calls = [System.Collections.Generic.List[object]]::new()
        BaseJson = [System.IO.File]::ReadAllText($path)
        RemoteJson = $RemoteJson
        PullRequestsJson = '[]'
        Failure = ''
        Dirty = $false
        Fork = $false
        Origin = 'https://github.com/Azure/terraform-azurerm-avm-utl-naming.git'
        BranchChanges = 'data/resource-name-rules.json'
        Head = ('a' * 40)
    }
    $runner = {
        param([string] $FileName, [string[]] $Arguments, [string] $Directory)
        $state.Calls.Add([pscustomobject] @{ FileName = $FileName; Arguments = $Arguments.Clone() })
        $offset = 0
        while ($Arguments[$offset] -eq '-c') {
            $offset += 2
        }
        $operation = $Arguments[$offset]
        $key = "$FileName`:$operation"
        if ($FileName -eq 'gh') {
            if ($operation -eq 'api' -and $Arguments[1] -eq '--method') {
                $key = "gh:$($Arguments[2])"
            }
            elseif ($operation -eq 'pr') {
                $key = "gh:$($Arguments[1])"
            }
        }
        if ($state.Failure -ceq $key) {
            return [pscustomobject] @{ ExitCode = 17; StdOut = ''; StdErr = 'Mocked failure.' }
        }
        $output = ''
        $code = 0
        switch ($key) {
            'git:status' { if ($state.Dirty) { $output = ' M unrelated.txt' } }
            'git:remote' { $output = $state.Origin }
            'git:check-ref-format' {}
            'git:fetch' {}
            'git:ls-remote' {
                if ($state.RemoteJson) {
                    $output = "$($state.Head)`trefs/heads/automation/resource-name-rules-additions`n"
                }
                else {
                    $code = 2
                }
            }
            'git:rev-parse' { $output = $state.Head }
            'git:merge-base' { $output = 'b' * 40 }
            'git:diff' {
                if ($Arguments -contains '--quiet') {
                    $code = 1
                }
                elseif ($Arguments -contains ('b' * 40)) {
                    $output = $state.BranchChanges
                }
                else {
                    $output = 'data/resource-name-rules.json'
                }
            }
            'git:show' { $output = $state.RemoteJson }
            'git:checkout' {
                [System.IO.File]::WriteAllText(
                    (Join-Path $Directory 'data' 'resource-name-rules.json'), $state.BaseJson,
                    [System.Text.UTF8Encoding]::new($false)
                )
            }
            'git:add' {}
            'git:commit' {}
            'git:push' {}
            'gh:api' {
                $output = @{
                    full_name = 'Azure/terraform-azurerm-avm-utl-naming'
                    default_branch = 'main'
                    fork = $state.Fork
                } | ConvertTo-Json -Compress
            }
            'gh:GET' { $output = $state.PullRequestsJson }
            'gh:PATCH' { $output = '{"number":7}' }
            'gh:create' { $output = 'https://github.com/Azure/terraform-azurerm-avm-utl-naming/pull/7' }
            default { throw "Unexpected mocked command: $FileName $($Arguments -join ' ')" }
        }
        return [pscustomobject] @{ ExitCode = $code; StdOut = $output; StdErr = '' }
    }.GetNewClosure()
    return [pscustomobject] @{ Root = $root; State = $state; Runner = $runner }
}

function Invoke-TestPublication {
    param($Context, [string] $Markdown = (New-TestDocument -Rows ($script:BaseRows + '| additions | global | 1-80 | Letters. |')))
    return Publish-ResourceNameRulesUpdate -Repository 'Azure/terraform-azurerm-avm-utl-naming' `
        -BaseBranch 'main' -RepositoryRoot $Context.Root -Markdown $Markdown -CommandRunner $Context.Runner
}

function New-TestPullRequestsJson {
    param(
        [string] $Title = 'old title',
        [string] $Body = 'old body',
        [string] $HeadRepository = 'Azure/terraform-azurerm-avm-utl-naming'
    )
    $pullRequest = @{
        number = 7
        title = $Title
        body = $Body
        head = @{ ref = 'automation/resource-name-rules-additions'; repo = @{ full_name = $HeadRepository } }
        base = @{ ref = 'main'; repo = @{ full_name = 'Azure/terraform-azurerm-avm-utl-naming' } }
    }
    return ConvertTo-Json -InputObject @($pullRequest) -Depth 8 -Compress
}

function Get-MockedCalls {
    param($Context, [string] $FileName, [string] $Argument)
    return @($Context.State.Calls | Where-Object { $_.FileName -ceq $FileName -and $_.Arguments -ccontains $Argument })
}

try {
    Test-Case 'representative tables, child paths, leading slash, preview headings, and reviewed FileShares alias' {
        $resources = ConvertFrom-ResourceNameRulesMarkdown -Markdown $script:RepresentativeDocument
        Assert-Equal $resources.Count 8
        Assert-True ($resources.Contains('microsoft.apimanagement/service/apis/operations/tags'))
        Assert-True ($resources.Contains('microsoft.kusto/clusters/databases'))
        Assert-True ($resources.Contains('microsoft.appconfiguration/configurationstores'))
        Assert-Equal $resources['microsoft.fileshares/fileshares'].source_entity 'file share'
        Assert-Equal $resources['microsoft.test/widgets'].source_heading 'Microsoft.Test (preview)'
        Assert-Equal $resources['microsoft.storage/storageaccounts/blobservices'].length ''
    }
    Test-Case 'escaped pipes, nested backtick delimiters, HTML code and attributes, and prose are preserved' {
        $resources = ConvertFrom-ResourceNameRulesMarkdown -Markdown $script:RepresentativeDocument
        Assert-Equal $resources['microsoft.test/widgets'].valid_characters 'Literal \|, `a|b`, ``a`|b``, <code>x|y</code>, and <span title="a|b">HTML</span>.'
        Assert-Equal $resources['microsoft.test/widgets/children'].valid_characters '&#124;<br/><br>Letters &amp; numbers.'
    }
    Test-Case 'formatting, qualified types, casing, quotes, and HTML normalize identities without additions' {
        $path = New-TestInventory
        $before = Get-FileBytes $path
        $source = (New-TestDocument).Replace('## Microsoft.Example', '## **MICROSOFT.EXAMPLE** ##').
            Replace('| widgets |', '| <code>microsoft.example / WIDGETS</code> |').
            Replace('| gadgets |', '| [**Gadgets**](https://example.invalid/types) |').
            Replace('Entity | Scope | Length | Valid Characters', '**Entity** | <b>Scope</b> | Length | Valid&nbsp;Characters').
            Replace("`n", "`r`n")
        $result = Update-ResourceNameRulesInventory -Markdown $source -InventoryPath $path
        Assert-Equal $result.AddedCount 0
        Assert-Equal (Get-FileBytes $path) $before
    }
    Test-Case 'column order can change without changing the identity or metadata mapping' {
        $source = New-TestDocument -Rows @('| 1-20 | Letters. | widgets | global |')
        $source = $source.Replace('Entity | Scope | Length | Valid Characters', 'Length | Valid Characters | Entity | Scope')
        $record = (ConvertFrom-ResourceNameRulesMarkdown -Markdown $source)['microsoft.example/widgets']
        Assert-Equal $record.scope 'global'
        Assert-Equal $record.length '1-20'
        Assert-Equal $record.valid_characters 'Letters.'
    }
    Test-Case 'individual segment emphasis, namespace emphasis, and underscores do not corrupt type identities' {
        $source = New-TestDocument -Rows @(
            '| **widgets** / *children* / _grandchildren_ | global | 1-63 | Letters. |',
            '| names_with_underscores | global | 1-63 | Letters. |'
        )
        $source = $source.Replace('## Microsoft.Example', '## **Microsoft.Example** (preview)')
        $resources = ConvertFrom-ResourceNameRulesMarkdown -Markdown $source
        Assert-True ($resources.Contains('microsoft.example/widgets/children/grandchildren'))
        Assert-True ($resources.Contains('microsoft.example/names_with_underscores'))
    }
    Test-Case 'duplicate and conflicting resource rows fail, including formatting and case aliases' {
        foreach ($duplicate in @(
            '| widgets | resource group | 1-63 | Alphanumerics and hyphens. |',
            '| **WIDGETS** | other scope | 3-99 | Different rule. |'
        )) {
            Assert-Throws { ConvertFrom-ResourceNameRulesMarkdown -Markdown (New-TestDocument -Rows ($script:BaseRows + $duplicate)) } 'Duplicate or conflicting'
        }
        $source = $script:RepresentativeDocument.Replace(
            '| file share | global | 3-63 | Lowercase letters, numbers, and hyphens. |',
            "| file share | global | 3-63 | Lowercase letters, numbers, and hyphens. |`n| fileShares | global | 3-63 | Same type. |"
        )
        Assert-Throws { ConvertFrom-ResourceNameRulesMarkdown -Markdown $source } 'Duplicate or conflicting'
    }
    Test-Case 'identical entity labels in different provider namespaces remain distinct' {
        $extra = "`n## Microsoft.Other`n| Entity | Scope | Length | Valid Characters |`n| --- | --- | --- | --- |`n| widgets | global | 1-80 | Letters. |`n`n"
        $source = (New-TestDocument).Replace($script:Footer, $extra + $script:Footer)
        Assert-Equal (ConvertFrom-ResourceNameRulesMarkdown -Markdown $source).Count 3
    }
    Test-Case 'invalid or truncated documents and malformed table layouts fail explicitly' {
        $valid = New-TestDocument
        $invalid = @(
            '',
            '<html><body>404 Not Found</body></html>',
            '{"message":"API rate limit exceeded"}',
            $valid.Replace('Naming rules and restrictions for Azure resources', 'Different document'),
            $valid.Substring(0, $valid.IndexOf('## Next steps')),
            $valid.Substring(0, $valid.LastIndexOf('resource-name.md') + 5),
            $valid.Replace('| --- | --- | --- | --- |', '| --- | --- | --- |'),
            $valid.Replace('| --- | --- | --- | --- |', '| xxx | --- | --- | --- |'),
            $valid.Replace('| Entity | Scope | Length | Valid Characters |', '| Entity | Scope | Length | Unexpected |'),
            $valid.Replace('## Microsoft.Example', '## Not a provider namespace'),
            $valid.Replace('| widgets |', '| unknown type |'),
            $valid.Replace('| widgets |', '| widgets // children |'),
            $valid.Replace('| widgets |', '| Microsoft.Other/widgets |'),
            $valid.Replace('| widgets | resource group |', '| widgets | |'),
            $valid.Replace('Alphanumerics and hyphens.', ''),
            $valid.Replace('Alphanumerics and hyphens.', '`unterminated | code'),
            $valid.Replace('Alphanumerics and hyphens.', '<code>unclosed|code'),
            (New-TestDocument -Rows @()),
            ('```markdown' + "`n" + $valid + "`n" + '```'),
            ($valid + "`n" + '```'),
            ("---`nunterminated front matter`n" + $valid.Substring($valid.IndexOf('# Naming'))),
            $valid.Replace('| gadgets |', '| gadgets | extra |')
        )
        foreach ($source in $invalid) {
            Assert-Throws { ConvertFrom-ResourceNameRulesMarkdown -Markdown $source }
        }
    }
    Test-Case 'repeated table headers and duplicate provider headings are rejected' {
        $source = New-TestDocument -Rows ($script:BaseRows + '| Entity | Scope | Length | Valid Characters |')
        Assert-Throws { ConvertFrom-ResourceNameRulesMarkdown -Markdown $source } 'repeated table header'
        $source = (New-TestDocument).Replace($script:Footer, "`n## MICROSOFT.EXAMPLE`n" + $script:Footer)
        Assert-Throws { ConvertFrom-ResourceNameRulesMarkdown -Markdown $source } 'Duplicate provider'
    }
    Test-Case 'missing inventory requires explicit initialization' {
        $path = Join-Path (New-TestDirectory) 'inventory.json'
        Assert-Throws { Update-ResourceNameRulesInventory -Markdown (New-TestDocument) -InventoryPath $path } 'missing'
        Assert-True (-not [System.IO.File]::Exists($path))
        $result = Update-ResourceNameRulesInventory -Markdown (New-TestDocument) -InventoryPath $path -Initialize
        Assert-Equal $result.AddedCount 2
    }
    Test-Case 'additions preserve changed and deleted upstream records and manual metadata' {
        $path = New-TestInventory
        $inventory = Read-ResourceNameRulesInventory $path
        $inventory.resources['microsoft.example/widgets'].review_note = 'Keep this exact manual metadata.'
        $inventory.review_policy = 'human approval'
        Write-ResourceNameRulesInventory -Inventory $inventory -Path $path
        $beforeWidgets = $inventory.resources['microsoft.example/widgets'] | ConvertTo-Json -Depth 8 -Compress
        $beforeGadgets = $inventory.resources['microsoft.example/gadgets'] | ConvertTo-Json -Depth 8 -Compress
        $source = New-TestDocument -Rows @(
            '| widgets | entirely changed | 100-999 | Changed upstream prose. |',
            '| additions / children | global | 1-80 | New rule. |'
        )
        $result = Update-ResourceNameRulesInventory -Markdown $source -InventoryPath $path
        $after = Read-ResourceNameRulesInventory $path
        Assert-Equal $result.AddedCount 1
        Assert-Equal $after.resources.Count 3
        Assert-Equal ($after.resources['microsoft.example/widgets'] | ConvertTo-Json -Depth 8 -Compress) $beforeWidgets
        Assert-Equal ($after.resources['microsoft.example/gadgets'] | ConvertTo-Json -Depth 8 -Compress) $beforeGadgets
        Assert-Equal $after.review_policy 'human approval'
    }
    Test-Case 'no-op and repeated additions are byte-stable and do not rewrite the file' {
        $path = New-TestInventory
        $source = New-TestDocument -Rows ($script:BaseRows + '| additions | global | 1-80 | Letters. |')
        $null = Update-ResourceNameRulesInventory -Markdown $source -InventoryPath $path
        $before = Get-FileBytes $path
        $writeTime = [System.IO.File]::GetLastWriteTimeUtc($path).Ticks
        $result = Update-ResourceNameRulesInventory -Markdown $source -InventoryPath $path
        Assert-Equal $result.AddedCount 0
        Assert-Equal (Get-FileBytes $path) $before
        Assert-Equal ([System.IO.File]::GetLastWriteTimeUtc($path).Ticks) $writeTime
        $result = Update-ResourceNameRulesInventory -Markdown (New-TestDocument -Rows @($script:BaseRows[0])) -InventoryPath $path
        Assert-Equal $result.AddedCount 0
        Assert-Equal (Get-FileBytes $path) $before
    }
    Test-Case 'input ordering cannot change inventory serialization' {
        $first = New-TestInventory
        $second = New-TestInventory -Markdown (New-TestDocument -Rows @($script:BaseRows[1], $script:BaseRows[0]))
        Assert-Equal (Get-FileBytes $first) (Get-FileBytes $second)
    }
    Test-Case 'ShouldProcess can preview additions without writing any inventory bytes' {
        $path = New-TestInventory
        $before = Get-FileBytes $path
        $source = New-TestDocument -Rows ($script:BaseRows + '| additions | global | 1-80 | Letters. |')
        $result = Update-ResourceNameRulesInventory -Markdown $source -InventoryPath $path -WhatIf
        Assert-Equal $result.AddedCount 1
        Assert-True (-not $result.Changed)
        Assert-Equal (Get-FileBytes $path) $before
    }
    Test-Case 'malformed input never changes an existing inventory or leaves staging files' {
        $path = New-TestInventory
        $before = Get-FileBytes $path
        Assert-Throws { Update-ResourceNameRulesInventory -Markdown 'Service unavailable' -InventoryPath $path }
        Assert-Equal (Get-FileBytes $path) $before
        Assert-Equal ([System.IO.Directory]::GetFiles((Split-Path $path -Parent), '*.new').Length) 0
    }
    Test-Case 'inventory JSON rejects duplicate properties, malformed JSON, wrong source and schema, and empty resources' {
        $path = New-TestInventory
        $valid = [System.IO.File]::ReadAllText($path)
        foreach ($json in @(
            'null', '[]', '{', '{}',
            $valid.Replace('"schema_version": 1', '"schema_version": 1, "schema_version": 1'),
            $valid.Replace('"schema_version": 1', '"schema_version": 1, "SCHEMA_VERSION": 1'),
            $valid.Replace('"schema_version": 1', '"schema_version": 99'),
            $valid.Replace((Get-ResourceNameRulesSourceUrl), 'https://example.invalid/untrusted'),
            $valid.Replace('"scope": "global"', '"scope": "global", "scope": "other"'),
            ('{"schema_version":1,"source_url":"' + (Get-ResourceNameRulesSourceUrl) + '","resources":{}}')
        )) {
            Assert-Throws { ConvertFrom-ResourceNameRulesInventoryJson -Json $json }
        }
    }
    Test-Case 'local fixture entry point performs the same safe update without downloading' {
        $root = New-TestDirectory
        $sourcePath = Join-Path $root 'fixture.md'
        $inventoryPath = Join-Path $root 'inventory.json'
        [System.IO.File]::WriteAllText($sourcePath, (New-TestDocument), [System.Text.UTF8Encoding]::new($false))
        $result = & (Join-Path $scriptsRoot 'Update-ResourceNameRules.ps1') -DocumentPath $sourcePath -InventoryPath $inventoryPath -Initialize
        Assert-Equal $result.AddedCount 2
        $result = & (Join-Path $scriptsRoot 'Update-ResourceNameRules.ps1') -DocumentPath $sourcePath -InventoryPath $inventoryPath
        Assert-Equal $result.AddedCount 0
    }
    Test-Case 'HTTP status, MIME, length, empty content, and invalid UTF-8 are validated without network' {
        foreach ($status in @(206, 301, 404, 429, 500)) {
            $response = New-TestResponse -Status $status
            try { Assert-Throws { ConvertFrom-ResourceNameRulesResponse $response } 'HTTP' }
            finally { $response.Dispose() }
        }
        foreach ($mime in @('text/html', 'application/json')) {
            $response = New-TestResponse -MediaType $mime
            try { Assert-Throws { ConvertFrom-ResourceNameRulesResponse $response } 'Markdown or plain text' }
            finally { $response.Dispose() }
        }
        $response = New-TestResponse
        try {
            Assert-Equal (ConvertFrom-ResourceNameRulesResponse $response) (New-TestDocument)
            $response.Content.Headers.ContentLength = 999999
            Assert-Throws { ConvertFrom-ResourceNameRulesResponse $response } 'truncated'
        }
        finally { $response.Dispose() }
        $response = New-TestResponse -Text ''
        try { Assert-Throws { ConvertFrom-ResourceNameRulesResponse $response } 'empty' }
        finally { $response.Dispose() }
        $response = New-TestResponse
        try {
            $response.Content.Dispose()
            $response.Content = [System.Net.Http.ByteArrayContent]::new([byte[]] @(255, 254, 255))
            $response.Content.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::new('text/plain')
            Assert-Throws { ConvertFrom-ResourceNameRulesResponse $response }
        }
        finally { $response.Dispose() }
    }
    Test-Case 'checked-in inventory is nonempty, canonical UTF-8 without BOM, and ordinally sorted' {
        $path = Join-Path $repositoryRoot 'data' 'resource-name-rules.json'
        $inventory = Read-ResourceNameRulesInventory $path
        Assert-True ($inventory.resources.Count -gt 0)
        $expected = [Convert]::ToBase64String([System.Text.UTF8Encoding]::new($false).GetBytes(
            (ConvertTo-ResourceNameRulesInventoryJson $inventory)
        ))
        Assert-Equal (Get-FileBytes $path) $expected
        [string[]] $keys = @($inventory.resources.Keys)
        [string[]] $sortedKeys = $keys.Clone()
        [Array]::Sort($sortedKeys, [StringComparer]::Ordinal)
        Assert-Equal ($keys -join "`n") ($sortedKeys -join "`n")
    }
    Test-Case 'publication no-op performs no commit, push, or pull request write' {
        $context = New-PublicationContext
        $result = Invoke-TestPublication -Context $context -Markdown (New-TestDocument)
        Assert-Equal $result.AddedCount 0
        Assert-Equal @(Get-MockedCalls $context 'git' 'push').Count 0
        Assert-Equal @(Get-MockedCalls $context 'git' 'commit').Count 0
        Assert-Equal @(Get-MockedCalls $context 'gh' 'create').Count 0
        Assert-Equal @(Get-MockedCalls $context 'gh' 'PATCH').Count 0
    }
    Test-Case 'publication creates a single inventory-only PR with a guarded push and static review boundary' {
        $context = New-PublicationContext
        $source = New-TestDocument -Rows ($script:BaseRows + '| additions | global | 1-80 | $(Invoke-Expression "bad") ${{ secrets.GITHUB_TOKEN }} |')
        $result = Invoke-TestPublication -Context $context -Markdown $source
        Assert-Equal $result.AddedCount 1
        Assert-True $result.Pushed
        $push = @(Get-MockedCalls $context 'git' 'push')
        Assert-Equal $push.Count 1
        Assert-True ($push[0].Arguments -ccontains '--force-with-lease=refs/heads/automation/resource-name-rules-additions:')
        Assert-True ($push[0].Arguments -ccontains 'credential.https://github.com.helper=!gh auth git-credential')
        $add = @(Get-MockedCalls $context 'git' 'add')
        Assert-Equal ($add[0].Arguments -join '|') 'add|--|data/resource-name-rules.json'
        $create = @(Get-MockedCalls $context 'gh' 'create')
        Assert-Equal $create.Count 1
        $body = $create[0].Arguments[[Array]::IndexOf($create[0].Arguments, '--body') + 1]
        Assert-True ($body.Contains('not an update to the module'))
        Assert-True ($body.Contains('never approves or automatically merges'))
        Assert-True (-not $body.Contains('Invoke-Expression'))
        Assert-True (-not $body.Contains('${{'))
        Assert-True ($create[0].Arguments -ccontains 'main')
    }
    Test-Case 'publication preserves pending additions deleted upstream and updates the existing PR' {
        $pendingPath = New-TestInventory -Markdown (New-TestDocument -Rows ($script:BaseRows + '| pending | global | 1-40 | Preserve pending prose. |'))
        $context = New-PublicationContext -RemoteJson ([System.IO.File]::ReadAllText($pendingPath))
        $context.State.PullRequestsJson = New-TestPullRequestsJson
        $result = Invoke-TestPublication $context
        $inventory = Read-ResourceNameRulesInventory (Join-Path $context.Root 'data' 'resource-name-rules.json')
        Assert-Equal $result.AddedCount 2
        Assert-Equal $inventory.resources['microsoft.example/pending'].valid_characters 'Preserve pending prose.'
        Assert-Equal @(Get-MockedCalls $context 'gh' 'create').Count 0
        Assert-Equal @(Get-MockedCalls $context 'gh' 'PATCH').Count 1
        $push = @(Get-MockedCalls $context 'git' 'push')[0]
        Assert-True ($push.Arguments -ccontains ('--force-with-lease=refs/heads/automation/resource-name-rules-additions:' + ('a' * 40)))
    }
    Test-Case 'repeated publication leaves the stable branch and matching PR unchanged' {
        $context = New-PublicationContext
        $null = Invoke-TestPublication $context
        $create = @(Get-MockedCalls $context 'gh' 'create')[0]
        $title = $create.Arguments[[Array]::IndexOf($create.Arguments, '--title') + 1]
        $body = $create.Arguments[[Array]::IndexOf($create.Arguments, '--body') + 1]
        $context.State.RemoteJson = [System.IO.File]::ReadAllText((Join-Path $context.Root 'data' 'resource-name-rules.json'))
        $context.State.PullRequestsJson = New-TestPullRequestsJson -Title $title -Body $body
        $context.State.Calls.Clear()
        $result = Invoke-TestPublication $context
        Assert-Equal $result.AddedCount 1
        Assert-True (-not $result.Pushed)
        Assert-Equal @(Get-MockedCalls $context 'git' 'push').Count 0
        Assert-Equal @(Get-MockedCalls $context 'git' 'commit').Count 0
        Assert-Equal @(Get-MockedCalls $context 'gh' 'create').Count 0
        Assert-Equal @(Get-MockedCalls $context 'gh' 'PATCH').Count 0
    }
    Test-Case 'a successful push followed by a PR failure is recovered without a redundant push' {
        $context = New-PublicationContext
        $context.State.Failure = 'gh:create'
        Assert-Throws { Invoke-TestPublication $context } 'command failed'
        $context.State.RemoteJson = [System.IO.File]::ReadAllText((Join-Path $context.Root 'data' 'resource-name-rules.json'))
        $context.State.Failure = ''
        $context.State.Calls.Clear()
        $result = Invoke-TestPublication $context
        Assert-True (-not $result.Pushed)
        Assert-Equal @(Get-MockedCalls $context 'git' 'push').Count 0
        Assert-Equal @(Get-MockedCalls $context 'gh' 'create').Count 1
    }
    Test-Case 'fetch, remote lookup, commit, push, and PR failures are never reported as no changes' {
        foreach ($failure in @('git:fetch', 'git:ls-remote', 'git:commit', 'git:push', 'gh:GET', 'gh:create', 'gh:PATCH')) {
            $context = New-PublicationContext
            $context.State.Failure = $failure
            if ($failure -eq 'gh:PATCH') {
                $context.State.PullRequestsJson = New-TestPullRequestsJson
            }
            Assert-Throws { Invoke-TestPublication $context } 'command failed'
            if ($failure -in @('git:fetch', 'git:ls-remote', 'git:commit', 'git:push')) {
                Assert-Equal @(Get-MockedCalls $context 'gh' 'create').Count 0
            }
        }
    }
    Test-Case 'PR-write failures explain the unverified repository-permission prerequisite' {
        foreach ($failure in @('gh:create', 'gh:PATCH')) {
            $context = New-PublicationContext
            $context.State.Failure = $failure
            if ($failure -eq 'gh:PATCH') {
                $context.State.PullRequestsJson = New-TestPullRequestsJson
            }
            Assert-Throws { Invoke-TestPublication $context } 'Allow GitHub Actions to create and approve pull requests.*enabled state must not be assumed'
        }
    }
    Test-Case 'forks, dirty checkouts, wrong remotes, wrong bases, and unexpected branch changes fail closed' {
        $context = New-PublicationContext
        $context.State.Fork = $true
        Assert-Throws { Invoke-TestPublication $context } 'fork'
        $context = New-PublicationContext
        $context.State.Dirty = $true
        Assert-Throws { Invoke-TestPublication $context } 'clean checkout'
        $context = New-PublicationContext
        $context.State.Origin = 'https://github.com/someone/fork.git'
        Assert-Throws { Invoke-TestPublication $context } 'origin remote'
        $context = New-PublicationContext
        Assert-Throws {
            Publish-ResourceNameRulesUpdate -Repository 'Azure/terraform-azurerm-avm-utl-naming' -BaseBranch 'other' `
                -RepositoryRoot $context.Root -Markdown (New-TestDocument) -CommandRunner $context.Runner
        } 'non-default'
        $context = New-PublicationContext -RemoteJson ([System.IO.File]::ReadAllText((New-TestInventory)))
        $context.State.BranchChanges = "data/resource-name-rules.json`nresourceDefinition.json"
        Assert-Throws { Invoke-TestPublication $context } 'outside the discovery inventory'
        Assert-Equal @(Get-MockedCalls $context 'git' 'push').Count 0
    }
    Test-Case 'a matching branch name from a different head repository cannot hijack PR updates' {
        $context = New-PublicationContext
        $context.State.PullRequestsJson = New-TestPullRequestsJson -HeadRepository 'Azure/unrelated-fork'
        Assert-Throws { Invoke-TestPublication $context } 'expected upstream branch'
        Assert-Equal @(Get-MockedCalls $context 'gh' 'PATCH').Count 0
        Assert-Equal @(Get-MockedCalls $context 'gh' 'create').Count 0
    }
    Test-Case 'malformed source fails before any publication command is invoked' {
        $context = New-PublicationContext
        Assert-Throws { Invoke-TestPublication -Context $context -Markdown 'Unavailable' }
        Assert-Equal $context.State.Calls.Count 0
    }
    Test-Case 'native command boundary captures failures without shell evaluation' {
        $result = Invoke-ResourceNameRulesNativeCommand -FileName 'pwsh' -ArgumentList @(
            '-NoProfile', '-NonInteractive', '-Command', '[Console]::Out.Write("expected"); exit 7'
        ) -WorkingDirectory $script:RunRoot
        Assert-Equal $result.ExitCode 7
        Assert-Equal $result.StdOut 'expected'
        Assert-Throws {
            Invoke-ResourceNameRulesNativeCommand -FileName 'pwsh' -ArgumentList @(
                '-NoProfile', '-NonInteractive', '-Command', 'Start-Sleep -Seconds 10'
            ) -WorkingDirectory $script:RunRoot -TimeoutSeconds 1
        } 'timeout'
    }
    Test-Case 'workflow boundaries use SHA pins, no persisted credentials, and isolated publication permissions' {
        $publishPath = Join-Path $repositoryRoot '.github' 'workflows' 'update-resource-name-rules.yml'
        $testPath = Join-Path $repositoryRoot '.github' 'workflows' 'naming-rules-tests.yml'
        $publish = [System.IO.File]::ReadAllText($publishPath)
        $tests = [System.IO.File]::ReadAllText($testPath)
        foreach ($workflow in @($publish, $tests)) {
            Assert-True ($workflow -match 'actions/checkout@[0-9a-f]{40}')
            Assert-True ($workflow.Contains('persist-credentials: false'))
            Assert-True ($workflow.Contains('permissions: {}'))
            Assert-True ($workflow.Contains('timeout-minutes:'))
            Assert-True (-not $workflow.Contains('pull_request_target:'))
        }
        Assert-True ($publish.Contains('cancel-in-progress: false'))
        Assert-True ($publish.Contains('github.event.repository.default_branch'))
        Assert-True ($publish.Contains('!github.event.repository.fork'))
        Assert-True ($publish.Contains('pull-requests: write'))
        Assert-True ($tests.Contains('contents: read'))
        Assert-True (-not $tests.Contains('GH_TOKEN'))
        Assert-True (-not $tests.Contains(': write'))
    }
}
finally {
    if ([System.IO.Directory]::Exists($script:RunRoot)) {
        [System.IO.Directory]::Delete($script:RunRoot, $true)
    }
}

Write-Information "Naming-rules tests: $script:Passed passed; $script:Failed failed. No network requests or remote writes were made." -InformationAction Continue
if ($script:Failed -gt 0) {
    throw "$script:Failed naming-rules tests failed."
}
