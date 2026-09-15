#requires -Version 7.4

[CmdletBinding()]
param(
    [string] $DocumentPath,
    [string] $AbbreviationsDocumentPath,
    [string] $GeneratedPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'data' 'resource-name-rules.json'),
    [string] $ManualPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'data' 'resource-name-rules.manual.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ResourceNameCatalog.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'ResourceNameRules.psm1')

$markdown = if ($DocumentPath) {
    [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $DocumentPath).Path, [System.Text.UTF8Encoding]::new($false, $true))
}
else { Get-ResourceNameRulesDocument }
$abbreviations = if ($AbbreviationsDocumentPath) {
    [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $AbbreviationsDocumentPath).Path, [System.Text.UTF8Encoding]::new($false, $true))
}
else { Get-ResourceNameRulesDocument -Uri (Get-ResourceAbbreviationsSourceUrl) }

Update-ResourceNameCatalog `
    -RulesMarkdown $markdown `
    -AbbreviationsMarkdown $abbreviations `
    -GeneratedPath $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($GeneratedPath) `
    -ManualPath $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ManualPath)
