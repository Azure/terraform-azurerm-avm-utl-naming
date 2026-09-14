#requires -Version 7.4
<#
.SYNOPSIS
Discovers additions to the documented Azure resource naming-rules inventory.
.DESCRIPTION
Only data/resource-name-rules.json is updated. Existing records, including changed
or deleted upstream rows, are preserved. Prose is never converted to runtime
definitions, Terraform outputs, slugs, or regular expressions.
.PARAMETER DocumentPath
Reads local Markdown instead of downloading the official document.
.PARAMETER Initialize
Allows deliberate creation of a missing inventory. Do not use in scheduled jobs.
#>
[CmdletBinding()]
param(
    [string] $DocumentPath,
    [string] $InventoryPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'data' 'resource-name-rules.json'),
    [switch] $Initialize
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ResourceNameRules.psm1') -Force

$markdown = if ($DocumentPath) {
    $document = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DocumentPath)
    [System.IO.File]::ReadAllText($document, [System.Text.UTF8Encoding]::new($false, $true))
}
else {
    Get-ResourceNameRulesDocument
}
$inventory = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InventoryPath)
$result = Update-ResourceNameRulesInventory -Markdown $markdown -InventoryPath $inventory -Initialize:$Initialize
Write-Information "Naming-rules inventory: $($result.AddedCount) additions; $($result.TotalCount) total records." -InformationAction Continue
$result
