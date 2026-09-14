#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ResourceNameRules.psm1')

function Invoke-ResourceNameRulesNativeCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $FileName,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $ArgumentList,
        [Parameter(Mandatory)][string] $WorkingDirectory,
        [ValidateRange(1, 300)][int] $TimeoutSeconds = 120
    )

    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $FileName
    $start.WorkingDirectory = $WorkingDirectory
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.StandardOutputEncoding = [System.Text.UTF8Encoding]::new($false, $true)
    $start.StandardErrorEncoding = [System.Text.UTF8Encoding]::new($false, $true)
    $start.Environment['GIT_TERMINAL_PROMPT'] = '0'
    $start.Environment['GH_PROMPT_DISABLED'] = '1'
    $start.Environment['GH_HOST'] = 'github.com'
    foreach ($argument in $ArgumentList) {
        [void] $start.ArgumentList.Add($argument)
    }
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $start
    try {
        if (-not $process.Start()) {
            throw "Could not start $FileName."
        }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw "$FileName exceeded the command timeout."
        }
        return [pscustomobject] @{
            ExitCode = $process.ExitCode
            StdOut = $stdout.GetAwaiter().GetResult()
            StdErr = $stderr.GetAwaiter().GetResult()
        }
    }
    finally {
        $process.Dispose()
    }
}

function Publish-ResourceNameRulesUpdate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Repository,
        [Parameter(Mandatory)][string] $BaseBranch,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Markdown,

        # Local tests replace the process boundary; remote content is never executable input.
        [scriptblock] $CommandRunner
    )

    $branch = 'automation/resource-name-rules-additions'
    $inventoryGitPath = 'data/resource-name-rules.json'
    $inventoryPath = Join-Path $RepositoryRoot 'data' 'resource-name-rules.json'
    if ($Repository -cne 'Azure/terraform-azurerm-avm-utl-naming') {
        throw 'Publication is restricted to the upstream naming module repository, never forks.'
    }
    if ([string]::IsNullOrWhiteSpace($BaseBranch) -or $BaseBranch -ceq $branch) {
        throw 'The publication base must be the repository default branch.'
    }
    $sourceResources = ConvertFrom-ResourceNameRulesMarkdown -Markdown $Markdown
    if ($null -eq $CommandRunner) {
        $CommandRunner = {
            param($FileName, $Arguments, $Directory)
            Invoke-ResourceNameRulesNativeCommand -FileName $FileName -ArgumentList $Arguments -WorkingDirectory $Directory
        }
    }
    $run = {
        param([string] $FileName, [string[]] $Arguments, [int[]] $AllowedExitCodes = @(0))
        $result = & $CommandRunner $FileName $Arguments $RepositoryRoot
        if ($null -eq $result) {
            throw "$FileName command returned no result; publication was not completed."
        }
        if ($result.ExitCode -notin $AllowedExitCodes) {
            $operationIndex = 0
            while ($Arguments[$operationIndex] -eq '-c') {
                $operationIndex += 2
            }
            $permissionHint = ''
            if ($FileName -eq 'gh' -and
                (($Arguments[0] -eq 'pr' -and $Arguments[1] -eq 'create') -or
                ($Arguments[0] -eq 'api' -and $Arguments -contains 'PATCH'))) {
                $permissionHint = ' For PR-write failures, verify GITHUB_TOKEN permissions and the repository prerequisite: Settings > Actions > General > Workflow permissions > Allow GitHub Actions to create and approve pull requests. This workflow does not verify or change that setting; its enabled state must not be assumed.'
            }
            throw "$FileName command failed during $($Arguments[$operationIndex]); publication was not completed (exit code $($result.ExitCode)).$permissionHint"
        }
        return $result
    }
    $authentication = @('-c', 'credential.helper=', '-c', 'credential.https://github.com.helper=!gh auth git-credential')
    $status = & $run 'git' @('status', '--porcelain', '--untracked-files=all')
    if (-not [string]::IsNullOrWhiteSpace($status.StdOut)) {
        throw 'Publication requires a clean checkout; refusing to include unrelated changes.'
    }
    $origin = (& $run 'git' @('remote', 'get-url', 'origin')).StdOut.Trim()
    if ($origin -notmatch ('^https://github\.com/' + [regex]::Escape($Repository) + '(?:\.git)?$')) {
        throw 'The origin remote is not the expected upstream GitHub repository.'
    }
    $repositoryInfo = (& $run 'gh' @('api', "repos/$Repository")).StdOut | ConvertFrom-Json -AsHashtable
    if ($repositoryInfo.fork -isnot [bool] -or $repositoryInfo.fork -or
        $repositoryInfo.full_name -cne $Repository -or $repositoryInfo.default_branch -cne $BaseBranch) {
        throw 'Refusing publication to a fork or a non-default base branch.'
    }
    $null = & $run 'git' @('check-ref-format', "refs/heads/$BaseBranch")
    $baseRef = "refs/remotes/origin/$BaseBranch"
    $updateRef = "refs/remotes/origin/$branch"
    $null = & $run 'git' ($authentication + @('fetch', '--no-tags', 'origin', "+refs/heads/${BaseBranch}:$baseRef"))
    $remote = & $run 'git' ($authentication + @('ls-remote', '--exit-code', '--heads', 'origin', "refs/heads/$branch")) @(0, 2)
    $remoteInventoryJson = $null
    $pendingInventory = $null
    $expectedHead = ''
    if ($remote.ExitCode -eq 0) {
        if ($remote.StdOut.Trim() -notmatch ('^[a-f0-9]{40}\s+refs/heads/' + [regex]::Escape($branch) + '$')) {
            throw 'Unexpected response while checking the update branch.'
        }
        $null = & $run 'git' ($authentication + @('fetch', '--no-tags', 'origin', "+refs/heads/${branch}:$updateRef"))
        $expectedHead = (& $run 'git' @('rev-parse', $updateRef)).StdOut.Trim()
        if ($expectedHead -notmatch '^[a-f0-9]{40}$') {
            throw 'Could not resolve the update branch commit.'
        }
        $commonBase = (& $run 'git' @('merge-base', $baseRef, $updateRef)).StdOut.Trim()
        if ($commonBase -notmatch '^[a-f0-9]{40}$') {
            throw 'The update branch has no verifiable common base.'
        }
        $branchChanges = (& $run 'git' @('diff', '--name-only', $commonBase, $updateRef)).StdOut.Trim()
        if ($branchChanges -ne '' -and $branchChanges -cne $inventoryGitPath) {
            throw 'The reserved automation branch contains changes outside the discovery inventory; refusing to overwrite them.'
        }
        $remoteInventoryJson = (& $run 'git' @('show', "${updateRef}:$inventoryGitPath")).StdOut
        $pendingInventory = ConvertFrom-ResourceNameRulesInventoryJson -Json $remoteInventoryJson
    }
    elseif (-not [string]::IsNullOrWhiteSpace($remote.StdOut)) {
        throw 'Unexpected output while checking for an absent update branch.'
    }

    $null = & $run 'git' @('checkout', '-B', $branch, $baseRef)
    $baseInventory = Read-ResourceNameRulesInventory -Path $inventoryPath
    $inventory = $baseInventory
    if ($null -ne $pendingInventory) {
        # Preserve pending proposals even if a subsequent source revision removes them.
        $inventory = Merge-ResourceNameRulesInventory -Inventory $inventory -Resources $pendingInventory.resources
    }
    $inventory = Merge-ResourceNameRulesInventory -Inventory $inventory -Resources $sourceResources
    $addedCount = $inventory.resources.Count - $baseInventory.resources.Count
    if ($addedCount -eq 0) {
        return [pscustomobject] @{ AddedCount = 0; Pushed = $false; PullRequestUrl = $null }
    }
    Write-ResourceNameRulesInventory -Inventory $inventory -Path $inventoryPath
    $difference = & $run 'git' @('diff', '--quiet', '--', $inventoryGitPath) @(0, 1)
    if ($difference.ExitCode -ne 1) {
        throw 'The inventory reported additions but git found no changes.'
    }
    if ((& $run 'git' @('diff', '--name-only')).StdOut.Trim() -cne $inventoryGitPath) {
        throw 'Discovery modified files outside its inventory; refusing publication.'
    }

    $json = ConvertTo-ResourceNameRulesInventoryJson -Inventory $inventory
    $pushed = $false
    if ($null -eq $remoteInventoryJson -or $json -cne $remoteInventoryJson) {
        $null = & $run 'git' @('add', '--', $inventoryGitPath)
        if ((& $run 'git' @('diff', '--cached', '--name-only')).StdOut.Trim() -cne $inventoryGitPath) {
            throw 'The staged update contains unexpected files.'
        }
        $commitMessage = "chore: discover documented Azure naming-rule additions`n`nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
        $null = & $run 'git' @(
            '-c', 'user.name=github-actions[bot]',
            '-c', 'user.email=41898282+github-actions[bot]@users.noreply.github.com',
            '-c', 'commit.gpgsign=false', 'commit', '-m', $commitMessage
        )
        $null = & $run 'git' ($authentication + @(
            'push', '--porcelain', "--force-with-lease=refs/heads/${branch}:$expectedHead",
            'origin', "HEAD:refs/heads/$branch"
        ))
        $pushed = $true
    }

    $title = 'chore: discover documented Azure naming-rule additions'
    $body = @'
## Additions-only documentation discovery

This pull request proposes __COUNT__ documented resource type additions to `data/resource-name-rules.json`, compared with the repository default branch.

Source: [Microsoft's Azure resource naming rules](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/azure-resource-manager/management/resource-name-rules.md).

### Review boundary

- This is a review inventory, **not an update to the module's runtime naming catalog**.
- Existing inventory records are never changed or deleted. Pending additions on this branch are preserved across runs.
- The original scope, length, and valid-characters prose is retained, including Markdown/HTML and upstream inaccuracies. Documented provider/entity notation can also include data-plane shorthand; it is not a validated ARM deployment schema.
- No Terraform output names, resource slugs, regexes, or naming definitions are inferred or generated. Neither `resourceDefinition.json` nor `resourceDefinition_out_of_docs.json` is modified.
- A maintainer must review each addition and, separately, choose an appropriate runtime definition and compatibility tests. Future reviewed JSON definitions can be exposed through the module's `names` map; existing iteration-1 names remain unchanged.
- **Human review is required. This workflow never approves or automatically merges pull requests.**

### Automation notes

The workflow runs its offline parser and mocked publication tests before publishing. `GITHUB_TOKEN`-created pull requests do not automatically trigger other event-based workflows; maintainers can run the manual **Naming rules tests** workflow and any additional required checks.

Repository prerequisite: **Settings > Actions > General > Workflow permissions > Allow GitHub Actions to create and approve pull requests** must be enabled by a maintainer. The workflow does not change that setting or approve pull requests.
'@
    $body = $body.Replace('__COUNT__', [string] $addedCount)
    $pullRequestsResult = & $run 'gh' @(
        'api', '--method', 'GET', "repos/$Repository/pulls",
        '-f', 'state=open', '-f', "head=Azure:$branch", '-f', "base=$BaseBranch", '-f', 'per_page=100'
    )
    $pullRequests = ConvertFrom-Json -InputObject $pullRequestsResult.StdOut -NoEnumerate
    if ($pullRequests -isnot [array] -or $pullRequests.Count -gt 1) {
        throw 'Expected zero or one open pull request for the stable update branch.'
    }
    if ($pullRequests.Count -eq 0) {
        $created = & $run 'gh' @(
            'pr', 'create', '--repo', $Repository, '--base', $BaseBranch, '--head', $branch,
            '--title', $title, '--body', $body
        )
        $pullRequestUrl = $created.StdOut.Trim()
        if ($pullRequestUrl -notmatch ('^https://github\.com/' + [regex]::Escape($Repository) + '/pull/[0-9]+$')) {
            throw 'GitHub did not return a verifiable pull request URL.'
        }
    }
    else {
        $pullRequest = $pullRequests[0]
        if (($pullRequest.number -isnot [long] -and $pullRequest.number -isnot [int]) -or $pullRequest.number -lt 1) {
            throw 'GitHub returned an invalid pull request number.'
        }
        if ($pullRequest.head.repo.full_name -cne $Repository -or $pullRequest.head.ref -cne $branch -or
            $pullRequest.base.repo.full_name -cne $Repository -or $pullRequest.base.ref -cne $BaseBranch) {
            throw 'The existing pull request does not belong to the expected upstream branch and base.'
        }
        if ($pullRequest.title -cne $title -or $pullRequest.body -cne $body) {
            $null = & $run 'gh' @(
                'api', '--method', 'PATCH', "repos/$Repository/pulls/$($pullRequest.number)",
                '-f', "title=$title", '-f', "body=$body"
            )
        }
        $pullRequestUrl = "https://github.com/$Repository/pull/$($pullRequest.number)"
    }
    return [pscustomobject] @{ AddedCount = $addedCount; Pushed = $pushed; PullRequestUrl = $pullRequestUrl }
}

Export-ModuleMember -Function Invoke-ResourceNameRulesNativeCommand, Publish-ResourceNameRulesUpdate
