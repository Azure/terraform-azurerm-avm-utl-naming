#requires -Version 7.4
<#
.SYNOPSIS
Publishes discovery-only inventory additions from the scheduled GitHub Actions job.
.DESCRIPTION
Uses one reserved branch and pull request, the actual repository default branch,
ephemeral gh credential helpers, and force-with-lease. Refuses forks and dirty
checkouts. The repository must allow GitHub Actions to create pull requests.
Tests invoke the underlying function with mocked git/gh commands, never this entry point.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ($env:GITHUB_ACTIONS -cne 'true' -or $env:GITHUB_EVENT_NAME -notin @('schedule', 'workflow_dispatch') -or
    $env:GITHUB_REPOSITORY -cne 'Azure/terraform-azurerm-avm-utl-naming' -or
    [string]::IsNullOrWhiteSpace($env:NAMING_RULES_BASE_BRANCH) -or
    $env:GITHUB_REF -cne "refs/heads/$($env:NAMING_RULES_BASE_BRANCH)" -or
    [string]::IsNullOrWhiteSpace($env:GH_TOKEN)) {
    throw 'Publication is only allowed from the authenticated upstream scheduled/manual workflow on its default branch.'
}

Import-Module (Join-Path $PSScriptRoot 'ResourceNameRules.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'ResourceNameRules.Automation.psm1') -Force
$result = Publish-ResourceNameRulesUpdate `
    -Repository $env:GITHUB_REPOSITORY `
    -BaseBranch $env:NAMING_RULES_BASE_BRANCH `
    -RepositoryRoot (Split-Path $PSScriptRoot -Parent) `
    -Markdown (Get-ResourceNameRulesDocument)

if ($result.AddedCount -eq 0) {
    Write-Information 'No new documented resource types; no push or pull request was needed.' -InformationAction Continue
}
else {
    Write-Information "Proposed $($result.AddedCount) inventory additions: $($result.PullRequestUrl)" -InformationAction Continue
}
