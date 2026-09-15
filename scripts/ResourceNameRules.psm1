#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:SourceUrl = 'https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/main/articles/azure-resource-manager/management/resource-name-rules.md'
$script:MaximumDocumentBytes = 2MB
$script:ResourceTypePattern = '^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z0-9]+)+/[A-Za-z][A-Za-z0-9_.-]*(?:/[A-Za-z][A-Za-z0-9_.-]*)*$'

function Get-ResourceNameRulesSourceUrl {
    return $script:SourceUrl
}

function ConvertFrom-ResourceNameRulesResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Net.Http.HttpResponseMessage] $Response
    )

    if ([int] $Response.StatusCode -ne 200) {
        throw "The naming-rules download returned HTTP $([int] $Response.StatusCode); expected a complete HTTP 200 response."
    }
    if ($null -eq $Response.Content.Headers.ContentType -or
        $Response.Content.Headers.ContentType.MediaType -notin @('text/plain', 'text/markdown')) {
        throw 'The naming-rules download did not return Markdown or plain text.'
    }
    $bytes = $Response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
    if ($bytes.Length -eq 0 -or $bytes.Length -gt $script:MaximumDocumentBytes) {
        throw 'The naming-rules download was empty or exceeded the document size limit.'
    }
    if ($null -ne $Response.Content.Headers.ContentLength -and
        $Response.Content.Headers.ContentLength -ne $bytes.Length) {
        throw 'The naming-rules download was truncated (Content-Length mismatch).'
    }
    return [System.Text.UTF8Encoding]::new($false, $true).GetString($bytes)
}

function Get-ResourceNameRulesDocument {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 300)]
        [int] $TimeoutSeconds = 60,

        [ValidateSet(
            'https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/main/articles/azure-resource-manager/management/resource-name-rules.md',
            'https://raw.githubusercontent.com/MicrosoftDocs/cloud-adoption-framework/main/docs/ready/azure-best-practices/resource-abbreviations.md'
        )]
        [string] $Uri = $script:SourceUrl
    )

    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect = $false
    $handler.UseDefaultCredentials = $false
    $client = [System.Net.Http.HttpClient]::new($handler)
    $response = $null
    try {
        $client.Timeout = [TimeSpan]::FromSeconds($TimeoutSeconds)
        $client.MaxResponseContentBufferSize = $script:MaximumDocumentBytes
        $client.DefaultRequestHeaders.UserAgent.ParseAdd('avm-naming-rules-discovery/1.0')
        $client.DefaultRequestHeaders.Accept.ParseAdd('text/plain')
        $response = $client.GetAsync($Uri).GetAwaiter().GetResult()
        return ConvertFrom-ResourceNameRulesResponse -Response $response
    }
    finally {
        if ($null -ne $response) {
            $response.Dispose()
        }
        $client.Dispose()
    }
}

function ConvertFrom-NamingRulesPresentation {
    param([AllowEmptyString()][string] $Text)

    $text = [System.Net.WebUtility]::HtmlDecode($Text)
    $text = $text -replace '(?i)<sup\b[^>]*>.*?</sup>', ''
    $text = $text -replace '\[\^[^\]]+\]', ''
    $text = $text -replace '\[([^\[\]]+)\]\([^)]*\)', '$1'
    $text = $text -replace '\[([^\[\]]+)\]\[[^\]]*\]', '$1'
    $text = $text -replace '(?i)<br\s*/?>', ' '
    $text = $text -replace '(?i)</?(?:a|b|code|em|i|span|strong|wbr)\b[^>]*>', ''
    $text = $text -replace '`+', ''
    $text = $text -replace '(?<![A-Za-z0-9])(\*\*|__|\*|_)(?=\S)(.+?)(?<=\S)\1(?![A-Za-z0-9])', '$2'
    $text = $text.Trim() -replace '(?:\\?\*)+$', ''
    return ($text -replace '\s+', ' ').Trim()
}

function Split-NamingRulesTableRow {
    param(
        [string] $Line,
        [int] $LineNumber
    )

    $cells = [System.Collections.Generic.List[string]]::new()
    $cell = [System.Text.StringBuilder]::new()
    $codeTicks = 0
    $htmlCode = $false
    for ($index = 0; $index -lt $Line.Length; $index++) {
        $character = $Line[$index]
        if ($character -eq '\' -and $codeTicks -eq 0 -and -not $htmlCode -and $index + 1 -lt $Line.Length) {
            [void] $cell.Append($character)
            [void] $cell.Append($Line[++$index])
            continue
        }
        if ($character -eq '`' -and -not $htmlCode) {
            $end = $index
            while ($end + 1 -lt $Line.Length -and $Line[$end + 1] -eq '`') {
                $end++
            }
            $count = $end - $index + 1
            if ($codeTicks -eq 0) {
                $codeTicks = $count
            }
            elseif ($codeTicks -eq $count) {
                $codeTicks = 0
            }
            [void] $cell.Append($Line.Substring($index, $count))
            $index = $end
            continue
        }
        if ($character -eq '<' -and $codeTicks -eq 0) {
            $tag = [regex]::Match($Line.Substring($index), '^</?[A-Za-z][A-Za-z0-9]*(?:\s[^<>]*?)?/?>')
            if ($tag.Success) {
                if ($tag.Value -match '(?i)^<code(?:\s|>)') {
                    if ($htmlCode) {
                        throw "Nested HTML code spans at document line $LineNumber."
                    }
                    $htmlCode = $true
                }
                elseif ($tag.Value -match '(?i)^</code\s*>') {
                    if (-not $htmlCode) {
                        throw "Unmatched HTML code span at document line $LineNumber."
                    }
                    $htmlCode = $false
                }
                [void] $cell.Append($tag.Value)
                $index += $tag.Length - 1
                continue
            }
        }
        if ($character -eq '|' -and $codeTicks -eq 0 -and -not $htmlCode) {
            $cells.Add($cell.ToString().Trim())
            [void] $cell.Clear()
        }
        else {
            [void] $cell.Append($character)
        }
    }
    if ($codeTicks -ne 0 -or $htmlCode) {
        throw "Unclosed code span at document line $LineNumber."
    }
    $cells.Add($cell.ToString().Trim())
    if ($Line.StartsWith('|')) {
        $cells.RemoveAt(0)
    }
    if ($Line.EndsWith('|') -and $cells[$cells.Count - 1] -eq '') {
        $cells.RemoveAt($cells.Count - 1)
    }
    return ,$cells.ToArray()
}

function Get-NamingRulesResourceType {
    param(
        [string] $Namespace,
        [string] $Entity,
        [int] $LineNumber
    )

    $entityText = ConvertFrom-NamingRulesPresentation -Text $Entity
    $entityText = $entityText -replace '\s*/\s*', '/'
    if ($entityText.StartsWith('/')) {
        $entityText = $entityText.Substring(1)
    }
    if ($entityText.StartsWith("$Namespace/", [StringComparison]::OrdinalIgnoreCase)) {
        $resourceType = $entityText
    }
    elseif ($entityText -match '^[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z0-9]+)+/') {
        throw "Resource type conflicts with its provider heading at document line $LineNumber."
    }
    else {
        $resourceType = "$Namespace/$entityText"
    }

    # The published label is prose, not an ARM type. This is a reviewed alias, not a whitespace heuristic.
    # https://learn.microsoft.com/azure/templates/microsoft.fileshares/fileshares
    if ($resourceType -ieq 'Microsoft.FileShares/file share') {
        $resourceType = 'Microsoft.FileShares/fileShares'
    }
    if ($resourceType -cnotmatch $script:ResourceTypePattern) {
        throw "Malformed or unrecognized resource type at document line $LineNumber; review the source instead of guessing a type."
    }
    return $resourceType
}

function Get-NamingRulesSortedKey {
    param([System.Collections.IDictionary] $Dictionary)

    [string[]] $keys = @($Dictionary.Keys)
    [Array]::Sort($keys, [StringComparer]::Ordinal)
    return ,$keys
}

function ConvertFrom-ResourceNameRulesMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Markdown
    )

    if ([string]::IsNullOrWhiteSpace($Markdown) -or $Markdown -match '[\x00-\x08\x0B\x0C\x0E-\x1F]') {
        throw 'The naming-rules document is empty or contains invalid control characters.'
    }
    $lines = ($Markdown.TrimStart([char] 0xFEFF) -replace "`r`n?", "`n") -split "`n"
    $resources = [System.Collections.Generic.Dictionary[string, object]]::new([StringComparer]::OrdinalIgnoreCase)
    $providers = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $namespace = $null
    $sourceHeading = $null
    $providerRows = 0
    $tableRows = 0
    $tableState = 'outside'
    $columns = @{}
    $titleSeen = $false
    $footerStart = -1
    $frontMatter = $lines[0].Trim() -eq '---'
    $fence = $null
    $expectedColumns = @('entity', 'scope', 'length', 'valid characters')

    for ($index = 0; $index -lt $lines.Length; $index++) {
        $lineNumber = $index + 1
        $line = ($lines[$index] -replace '^\s*(?:>\s*)+', '').Trim()
        if ($frontMatter) {
            if ($index -gt 0 -and $line -eq '---') {
                $frontMatter = $false
            }
            continue
        }
        if ($line -match '^(`{3,}|~{3,})') {
            if ($null -eq $fence) {
                $fence = $Matches[1]
            }
            elseif ($line -match ('^' + [regex]::Escape($fence[0]) + '{' + $fence.Length + ',}\s*$')) {
                $fence = $null
            }
            continue
        }
        if ($null -ne $fence) {
            continue
        }
        if ($line -match '^(#{1,6})\s+(.+?)(?:\s+#+)?$') {
            $level = $Matches[1].Length
            $heading = ConvertFrom-NamingRulesPresentation -Text $Matches[2]
            if ($tableState -eq 'separator' -or ($tableState -eq 'rows' -and $tableRows -eq 0)) {
                throw "Incomplete naming-rules table before document line $lineNumber."
            }
            $tableState = 'outside'
            if ($level -eq 1) {
                if ($titleSeen -or $heading -ine 'Naming rules and restrictions for Azure resources') {
                    throw 'The download is not the expected Azure resource naming-rules document.'
                }
                $titleSeen = $true
                continue
            }
            if ($level -eq 2) {
                if ($null -ne $namespace -and $providerRows -eq 0) {
                    throw "Provider section without any naming-rule rows before document line $lineNumber."
                }
                $namespace = $null
                if ($heading -ieq 'Next steps') {
                    if ($footerStart -ge 0) {
                        throw 'Duplicate Next steps footer in the naming-rules document.'
                    }
                    $footerStart = $index
                }
                elseif ($heading -match '^([A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z0-9]+)+)(?:\s+\([^()]+\))?$') {
                    if (-not $titleSeen -or $footerStart -ge 0) {
                        throw 'Provider table outside the expected document body.'
                    }
                    $namespace = $Matches[1]
                    $sourceHeading = $heading
                    $providerRows = 0
                    if (-not $providers.Add($namespace)) {
                        throw "Duplicate provider heading at document line $lineNumber."
                    }
                }
            }
            continue
        }

        $tableLike = $line.StartsWith('|') -or
            ($line.Contains('|') -and ($tableState -ne 'outside' -or $line -match '(?i)\b(entity|scope|length|valid characters)\b'))
        if ($tableLike) {
            if ($null -eq $namespace -or $footerStart -ge 0) {
                throw "Naming-rules table has no recognized provider heading at document line $lineNumber."
            }
            $cells = Split-NamingRulesTableRow -Line $line -LineNumber $lineNumber
            if ($cells.Count -ne 4) {
                throw "Expected four naming-rule columns at document line $lineNumber; found $($cells.Count)."
            }
            if ($tableState -eq 'outside') {
                $columns = @{}
                for ($column = 0; $column -lt 4; $column++) {
                    $name = (ConvertFrom-NamingRulesPresentation -Text $cells[$column]).ToLowerInvariant()
                    if ($name -notin $expectedColumns -or $columns.ContainsKey($name)) {
                        throw "Unexpected or duplicate table column at document line $lineNumber."
                    }
                    $columns[$name] = $column
                }
                $tableRows = 0
                $tableState = 'separator'
                continue
            }
            if ($tableState -eq 'separator') {
                foreach ($cell in $cells) {
                    if ($cell -notmatch '^:?-{3,}:?$') {
                        throw "Malformed table separator at document line $lineNumber."
                    }
                }
                $tableState = 'rows'
                continue
            }
            $headerCells = @($cells | ForEach-Object { (ConvertFrom-NamingRulesPresentation -Text $_).ToLowerInvariant() })
            if (@($headerCells | Where-Object { $_ -in $expectedColumns }).Count -eq 4) {
                throw "Unexpected repeated table header at document line $lineNumber."
            }
            $entity = $cells[$columns.entity]
            $scope = $cells[$columns.scope]
            $length = $cells[$columns.length]
            $validCharacters = $cells[$columns['valid characters']]
            if ([string]::IsNullOrWhiteSpace($entity) -or [string]::IsNullOrWhiteSpace($scope) -or
                [string]::IsNullOrWhiteSpace($validCharacters)) {
                throw "Empty entity, scope, or valid-characters cell at document line $lineNumber."
            }
            $resourceType = Get-NamingRulesResourceType -Namespace $namespace -Entity $entity -LineNumber $lineNumber
            $key = $resourceType.ToLowerInvariant()
            if ($resources.ContainsKey($key)) {
                throw "Duplicate or conflicting resource type '$key' at document line $lineNumber."
            }
            $resources.Add($key, [ordered] @{
                resource_type = $resourceType
                source_heading = $sourceHeading
                source_entity = $entity
                scope = $scope
                length = $length
                valid_characters = $validCharacters
            })
            $providerRows++
            $tableRows++
            continue
        }
        if ($tableState -eq 'separator' -or ($tableState -eq 'rows' -and $tableRows -eq 0)) {
            throw "Incomplete naming-rules table at document line $lineNumber."
        }
        $tableState = 'outside'
    }

    if ($frontMatter -or $null -ne $fence -or -not $titleSeen -or $resources.Count -eq 0 -or
        $footerStart -lt 0 -or ($null -ne $namespace -and $providerRows -eq 0)) {
        throw 'Incomplete or unexpected naming-rules document: require the title, populated provider tables, and a complete Next steps footer.'
    }
    $footer = $lines[$footerStart..($lines.Length - 1)] -join "`n"
    if ($footer -notmatch '\]\([^)\r\n]*naming-and-tagging\)' -or
        $footer -notmatch '\]\([^)\r\n]*error-reserved-resource-name\.md\)') {
        throw 'The naming-rules document footer is incomplete; refusing a possibly truncated download.'
    }
    $sorted = [ordered] @{}
    foreach ($key in (Get-NamingRulesSortedKey -Dictionary $resources)) {
        $sorted[$key] = $resources[$key]
    }
    return $sorted
}

function Assert-NamingRulesJsonProperty {
    param([System.Text.Json.JsonElement] $Element)

    if ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Object) {
        $names = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($property in $Element.EnumerateObject()) {
            if (-not $names.Add($property.Name)) {
                throw 'Duplicate or case-conflicting JSON property in the naming-rules inventory.'
            }
            Assert-NamingRulesJsonProperty -Element $property.Value
        }
    }
    elseif ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Array) {
        foreach ($item in $Element.EnumerateArray()) {
            Assert-NamingRulesJsonProperty -Element $item
        }
    }
}

Export-ModuleMember -Function Get-ResourceNameRulesSourceUrl, Get-ResourceNameRulesDocument,
    ConvertFrom-ResourceNameRulesResponse, ConvertFrom-ResourceNameRulesMarkdown,
    ConvertFrom-NamingRulesPresentation, Split-NamingRulesTableRow,
    Get-NamingRulesSortedKey, Assert-NamingRulesJsonProperty
