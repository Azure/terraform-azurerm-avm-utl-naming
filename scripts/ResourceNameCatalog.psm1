#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ResourceNameRules.psm1')
$script:AbbreviationsUrl = 'https://raw.githubusercontent.com/MicrosoftDocs/cloud-adoption-framework/main/docs/ready/azure-best-practices/resource-abbreviations.md'

function Get-ResourceAbbreviationsSourceUrl {
    return $script:AbbreviationsUrl
}

function ConvertTo-NamingSnakeCase {
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)

    $text = $Text -creplace '([A-Z]{2,})s\b', '$1'
    $text = $text -creplace '([A-Z]+)([A-Z][a-z])', '$1_$2'
    $text = $text -creplace '([a-z0-9])([A-Z])', '$1_$2'
    return ($text.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim('_')
}

function ConvertTo-NamingSingular {
    param([Parameter(Mandatory)][string] $Text)

    $words = $Text -split '_'
    $last = $words[-1]
    if ($last -eq 'caches') { $last = 'cache' }
    elseif ($last -notin @('analysis', 'access', 'dns', 'redis', 'series', 'species', 'status') -and $last -notmatch '(ss|us)$') {
        if ($last -match 'ies$') { $last = $last.Substring(0, $last.Length - 3) + 'y' }
        elseif ($last -match '(ches|shes|sses|xes|zes)$') { $last = $last.Substring(0, $last.Length - 2) }
        elseif ($last.EndsWith('s') -and $last.Length -gt 1) { $last = $last.Substring(0, $last.Length - 1) }
    }
    $words[-1] = $last
    return $words -join '_'
}

function ConvertTo-NamingTerraformKey {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $ResourceType)

    $segments = $ResourceType -split '/'
    if ($segments.Count -lt 2) { throw "Expected a qualified resource type: $ResourceType" }
    return (@($segments[1..($segments.Count - 1)] | ForEach-Object {
        ConvertTo-NamingSingular (ConvertTo-NamingSnakeCase $_)
    }) -join '_')
}

function Resolve-NamingResourceType {
    param([Parameter(Mandatory)][string] $ResourceType)

    # These are source-table discrepancies, verified against the matching ARM reference pages.
    switch ($ResourceType.ToLowerInvariant()) {
        # https://learn.microsoft.com/azure/templates/microsoft.databricks/accessconnectors
        'microsoft.databricks/workspaces/accessconnectors' { return 'Microsoft.Databricks/accessConnectors' }
        # https://learn.microsoft.com/azure/templates/microsoft.sql/servers/elasticpools
        'microsoft.sql/servers/elasticpool' { return 'Microsoft.Sql/servers/elasticPools' }
        # https://learn.microsoft.com/azure/templates/microsoft.network/dnsforwardingrulesets
        'microsoft.network/dnsforwardingruleset' { return 'Microsoft.Network/dnsForwardingRulesets' }
        # https://learn.microsoft.com/azure/templates/microsoft.streamanalytics/clusters
        'microsoft.streamanalytics/cluster' { return 'Microsoft.StreamAnalytics/clusters' }
        # https://learn.microsoft.com/azure/templates/microsoft.network/vpnsites
        'microsoft.network/vpngateways/vpnsites' { return 'Microsoft.Network/vpnSites' }
        default { return $ResourceType }
    }
}

function ConvertFrom-ResourceAbbreviationsMarkdown {
    [CmdletBinding()]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Markdown)

    if ($Markdown -notmatch '(?m)^# Abbreviation recommendations for Azure resources\s*$' -or
        $Markdown -notmatch '(?m)^## Next step\s*$' -or $Markdown -notmatch 'resource-tagging\.md') {
        throw 'Incomplete or unexpected CAF abbreviation document.'
    }
    $rows = [System.Collections.Generic.List[object]]::new()
    $lineNumber = 0
    foreach ($line in ($Markdown -split '\r?\n')) {
        $lineNumber++
        if (-not $line.TrimStart().StartsWith('|')) { continue }
        $cells = Split-NamingRulesTableRow -Line $line.Trim() -LineNumber $lineNumber
        if ($cells.Count -ne 3) { throw "Expected three CAF table columns at line $lineNumber." }
        if ($cells[0] -eq 'Resource' -or $cells[0] -match '^:?-+:?$') { continue }
        $namespace = ConvertFrom-NamingRulesPresentation $cells[1]
        if ($namespace -notmatch '^(?<type>[A-Za-z][A-Za-z0-9.]+/[A-Za-z0-9_./-]+)(?:\s+\((?<qualifier>kind|mode):\s*(?<value>[^)]+)\))?$') {
            throw "Unrecognized CAF resource type at line $lineNumber."
        }
        $type = Resolve-NamingResourceType $Matches.type
        $qualifier = if ($Matches.ContainsKey('qualifier')) { $Matches.qualifier } else { $null }
        $value = if ($Matches.ContainsKey('value')) { $Matches.value.Trim() } else { $null }
        $label = ConvertFrom-NamingRulesPresentation $cells[0]
        # https://learn.microsoft.com/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies
        if ($type -ieq 'Microsoft.Network/firewallPolicies' -and $label -match '^Web Application Firewall.*policy$') {
            $type = 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies'
        }
        $abbreviation = ConvertFrom-NamingRulesPresentation $cells[2]
        $literal = $abbreviation -cmatch '^[a-z][a-z0-9-]*$'
        $rows.Add([ordered]@{
            resource_type = $type
            label = $label
            qualifier = $qualifier
            qualifier_value = $value
            resource_provider_namespace_text = $cells[1]
            abbreviation = if ($literal) { $abbreviation } else { $null }
            abbreviation_text = $cells[2]
        })
    }
    if ($rows.Count -eq 0) { throw 'The CAF document contains no abbreviation rows.' }
    return ,$rows.ToArray()
}

function Get-NamingSectionNote {
    param([Parameter(Mandatory)][string] $Markdown)

    $notes = @{}
    $namespace = $null
    foreach ($line in ($Markdown -split '\r?\n')) {
        $text = ($line -replace '^\s*(?:>\s*)+', '').Trim()
        if ($text -match '^##\s+([A-Za-z][A-Za-z0-9.]+)(?:\s+\([^)]*\))?$') {
            $namespace = $Matches[1].ToLowerInvariant()
            $notes[$namespace] = [System.Collections.Generic.List[string]]::new()
        }
        elseif ($text -match '^## ') { $namespace = $null }
        elseif ($null -ne $namespace -and $text -ne '' -and -not $text.StartsWith('|') -and $text -notmatch '^\[!') {
            $notes[$namespace].Add($text)
        }
    }
    return $notes
}

function ConvertTo-NamingCharacterClass {
    param([Parameter(Mandatory)][string] $Characters)

    $escaped = foreach ($character in $Characters.ToCharArray()) {
        if ($character -in @('\', '-', '[', ']', '^')) { '\' + $character }
        else { [string] $character }
    }
    return (($escaped -join '') -replace 'abcdefghijklmnopqrstuvwxyz', 'a-z' -replace 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'A-Z' -replace '0123456789', '0-9')
}

function ConvertTo-NamingRuntimeRule {
    param(
        [AllowNull()][System.Collections.IDictionary] $Rule,
        [AllowEmptyCollection()][string[]] $SectionNotes = @()
    )

    $SectionNotes = @($SectionNotes | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $result = [ordered]@{
        min_length = $null; max_length = $null; scope = $null; regex = $null
        dashes = $false; lowercase = $true; name_kind = 'standard'; fixed_name = $null
        validation_complete = $false; validation_notes = @()
        forbidden_prefixes = @(); forbidden_suffixes = @(); forbidden_sequences = @(); reserved_names = @()
    }
    $limitations = [System.Collections.Generic.List[string]]::new()
    if ($null -eq $Rule) {
        $limitations.Add('No naming-rule row exists in the selected naming-rules document; generation uses conservative lowercase, separator-free components.')
        $result.validation_notes = $limitations.ToArray()
        return $result
    }
    $result.scope = ConvertFrom-NamingRulesPresentation $Rule.scope
    $length = ConvertFrom-NamingRulesPresentation $Rule.length
    $text = ConvertFrom-NamingRulesPresentation $Rule.valid_characters
    $text = $text -replace '^nLowercase\b', 'Lowercase'
    if ($length -match '^(?<min>\d+)\s*-\s*(?<max>\d+)$') {
        $result.min_length = [int] $Matches.min
        $result.max_length = [int] $Matches.max
    }
    elseif ($length -match '^\d+$' -and $text -match '\bGUID\b') {
        $result.min_length = [int] $length
        $result.max_length = [int] $length
    }
    elseif ($length -match '^\d+$') {
        $result.max_length = [int] $length
        $limitations.Add('The length cell provides one number without an explicit lower bound.')
    }
    else { $limitations.Add('The documented length is missing, composite, or conditional; no universal bounds are asserted.') }

    if ($text -match '(?i)^(?:GUID|Must be a globally unique identifier \(GUID\))\.?$') {
        $result.name_kind = 'uuid'
        $result.regex = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    }
    elseif ($text -match '(?i)^(?:Use|Must be|Must be named)\s+[''"]?(?<literal>default|current|web)[''"]?\.?$') {
        $result.name_kind = 'literal'
        $result.fixed_name = $Matches.literal
        $result.regex = '^' + [regex]::Escape($Matches.literal) + '$'
    }
    elseif ($text -match 'Char\.IsLetterOrDigit') {
        $result.dashes = $text -match '(?i)\bhyphens\b'
        $result.lowercase = $false
        $punctuation = ''
        foreach ($item in @(@('underscores', '_'), @('hyphens', '\-'), @('periods', '\.'), @('parentheses', '()'))) {
            if ($text -match ('(?i)\b' + $item[0] + '\b')) { $punctuation += $item[1] }
        }
        $result.regex = '^[\p{L}\p{Nd}' + $punctuation + ']+$'
        if ($text -match '(?i)Can''t end with period') { $result.forbidden_suffixes = @('.') }
        $limitations.Add('Unicode character categories are represented, but the linked platform-specific character semantics are not claimed to be fully equivalent.')
    }
    elseif ($text -match '^(?i)(Alphanumerics?|Lowercase letters and numbers|Uppercase letters and numbers)') {
        $lower = 'abcdefghijklmnopqrstuvwxyz'
        $upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        $digits = '0123456789'
        $letters = if ($text -match '^Lowercase') { $lower } elseif ($text -match '^Uppercase') { $upper } else { $lower + $upper }
        $result.lowercase = $text -match '^Lowercase'
        $firstClause = ($text -split '\.\s+|(?i)\s+(?=Start|End|Can''t|Cannot|Must|See|Use)', 2)[0].TrimEnd('.')
        $allowed = $letters + $digits
        $remainder = $text.Substring([Math]::Min($firstClause.Length, $text.Length)).Trim()
        $unknownClause = $firstClause -replace '^(?i)(Alphanumerics?|Lowercase letters and numbers|Uppercase letters and numbers)', ''
        foreach ($item in @(@('hyphens?', '-'), @('underscores?', '_'), @('periods?', '.'), @('parentheses', '()'))) {
            if ($unknownClause -match ('(?i)\b' + $item[0] + '\b')) {
                $allowed += $item[1]
                $unknownClause = $unknownClause -replace ('(?i)\b' + $item[0] + '\b'), ''
            }
        }
        $unknownClause = $unknownClause -replace '(?i)\band\b|[,\s.]', ''
        if ($unknownClause -ne '') { $limitations.Add('The allowed-character clause contains unsupported qualifiers.') }
        $result.dashes = $allowed.Contains('-')
        $first = $allowed
        $last = $allowed
        if ($remainder -match '(?i)Start with (?:a )?(lowercase letter|letter|alphanumeric)(?: character)?\.?') {
            $matched = $Matches[0]
            $first = if ($Matches[1] -eq 'alphanumeric') { $letters + $digits } else { $letters }
            $remainder = $remainder.Replace($matched, '')
        }
        if ($remainder -match '(?i)Start and end with (?:an? )?alphanumeric(?: or underscore)?\.?') {
            $matched = $Matches[0]
            $first = $letters + $digits + $(if ($matched -match 'underscore') { '_' } else { '' })
            $last = $first
            $remainder = $remainder.Replace($matched, '')
        }
        if ($remainder -match '(?i)End with (?:an? )?(alphanumeric|letter)(?: character)?\.?') {
            $matched = $Matches[0]
            $last = if ($Matches[1] -eq 'letter') { $letters } else { $letters + $digits }
            $remainder = $remainder.Replace($matched, '')
        }
        foreach ($restriction in @(
            @('(?i)(?:Can''t|Cannot) (?:use|contain) consecutive hyphens\.?', 'forbidden_sequences', '--'),
            @('(?i)(?:Can''t|Cannot) end with (?:a )?hyphen\.?', 'forbidden_suffixes', '-'),
            @('(?i)(?:Can''t|Cannot) end with (?:a )?period\.?', 'forbidden_suffixes', '.'),
            @('(?i)(?:Can''t|Cannot) start with (?:a )?hyphen\.?', 'forbidden_prefixes', '-')
        )) {
            if ($remainder -match $restriction[0]) {
                $remainder = $remainder.Replace($Matches[0], '')
                $result[$restriction[1]] = @($result[$restriction[1]]) + @($restriction[2])
            }
        }
        if (($remainder -replace '[\s.]', '') -ne '') { $limitations.Add('Additional character-rule prose is retained but not completely interpreted.') }
        $single = -join @($first.ToCharArray() | Where-Object { $last.Contains([string] $_) })
        $middleClass = ConvertTo-NamingCharacterClass $allowed
        $firstClass = ConvertTo-NamingCharacterClass $first
        $lastClass = ConvertTo-NamingCharacterClass $last
        $singleClass = ConvertTo-NamingCharacterClass $single
        $result.regex = "^(?:[$singleClass]|[$firstClass][$middleClass]*[$lastClass])$"
    }
    else { $limitations.Add('The character-rule prose is not represented by a complete RE2 rule.') }

    if ($SectionNotes.Count -gt 0) { $limitations.Add('Provider-section notes are retained for review and are not universally interpreted.') }
    if ($Rule.resource_type -ieq 'Microsoft.Compute/virtualMachines' -and
        ($SectionNotes -join ' ') -match '(?i)resource name.{0,160}64') {
        $result.min_length = $null
        $result.max_length = 64
        $result.regex = $null
        $limitations.Add('The table describes host names; the section note permits resource names up to 64 characters. Host-name rules are not asserted as ARM resource-name rules.')
    }
    $result.validation_complete = $limitations.Count -eq 0
    $result.validation_notes = $limitations.ToArray()
    return $result
}

function Get-NamingAbbreviationVariant {
    param([System.Collections.IDictionary] $Row, [bool] $Multiple)

    if ($null -ne $Row.qualifier_value) { return ConvertTo-NamingSnakeCase $Row.qualifier_value }
    if (-not $Multiple) { return $null }
    $label = $Row.label -replace '^(?i)Azure\s+', ''
    $provider = ($Row.resource_type -split '/')[0] -replace '^[^.]+\.', ''
    $label = $label -replace ('^(?i)' + [regex]::Escape($provider) + '\s*[-:]\s*'), ''
    $labelKey = ConvertTo-NamingSingular (ConvertTo-NamingSnakeCase $label)
    $leafKey = ConvertTo-NamingSingular (ConvertTo-NamingSnakeCase (($Row.resource_type -split '/')[-1]))
    if ($labelKey -eq $leafKey) { return $null }
    if ($labelKey.EndsWith("_$leafKey")) { $labelKey = $labelKey.Substring(0, $labelKey.Length - $leafKey.Length - 1) }
    return $labelKey
}

function ConvertTo-NamingCatalogJson {
    param([Parameter(Mandatory)][System.Collections.IDictionary] $Catalog)
    return (($Catalog | ConvertTo-Json -Depth 40) -replace "`r`n?", "`n") + "`n"
}

function ConvertFrom-NamingCatalogJson {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $Json)

    $document = [System.Text.Json.JsonDocument]::Parse($Json)
    try { Assert-NamingRulesJsonProperty $document.RootElement }
    finally { $document.Dispose() }
    $catalog = ConvertFrom-Json -InputObject $Json -AsHashtable -Depth 40
    if (($catalog.schema_version -isnot [int] -and $catalog.schema_version -isnot [long]) -or
        $catalog.schema_version -ne 2 -or $catalog.resources -isnot [System.Collections.IDictionary]) {
        throw 'Expected a schema-v2 naming catalog with a resources object.'
    }
    foreach ($key in $catalog.resources.Keys) {
        if ($key -cnotmatch '^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$') { throw "Invalid Terraform catalog key: $key" }
        $record = $catalog.resources[$key]
        if ($record -isnot [System.Collections.IDictionary]) { throw "Catalog entry '$key' must be an object." }
        foreach ($field in @('resource_type', 'variant', 'slug', 'slug_source', 'legacy_slug', 'legacy_outputs',
            'min_length', 'max_length', 'scope', 'regex', 'dashes', 'lowercase', 'name_kind', 'fixed_name',
            'validation_complete', 'validation_notes', 'forbidden_prefixes', 'forbidden_suffixes',
            'forbidden_sequences', 'reserved_names')) {
            if (-not $record.Contains($field)) { throw "Catalog entry '$key' is missing '$field'." }
        }
        foreach ($field in @('dashes', 'lowercase', 'validation_complete')) {
            if ($record[$field] -isnot [bool]) { throw "Catalog entry '$key' has a non-boolean '$field'." }
        }
        foreach ($field in @('resource_type', 'variant', 'legacy_slug', 'scope', 'regex', 'fixed_name')) {
            if ($null -ne $record[$field] -and $record[$field] -isnot [string]) {
                throw "Catalog entry '$key' has a non-string '$field'."
            }
        }
        foreach ($field in @('legacy_outputs', 'validation_notes', 'forbidden_prefixes', 'forbidden_suffixes', 'forbidden_sequences', 'reserved_names')) {
            if ($record[$field] -isnot [array] -or @($record[$field] | Where-Object { $_ -isnot [string] }).Count -gt 0) {
                throw "Catalog entry '$key' requires a string array for '$field'."
            }
        }
        foreach ($field in @('min_length', 'max_length')) {
            if ($null -ne $record[$field] -and ($record[$field] -isnot [long] -and $record[$field] -isnot [int])) {
                throw "Catalog entry '$key' has a non-integer '$field'."
            }
            if ($null -ne $record[$field] -and $record[$field] -lt 0) { throw "Negative length in '$key'." }
        }
        if ($null -ne $record.min_length -and $null -ne $record.max_length -and $record.min_length -gt $record.max_length) {
            throw "Reversed length bounds in '$key'."
        }
        if ($record.slug -isnot [string] -or $record.slug_source -notin @('caf', 'derived', 'manual') -or
            $record.name_kind -notin @('standard', 'uuid', 'literal') -or
            ($record.name_kind -eq 'literal' -and $record.fixed_name -isnot [string])) {
            throw "Invalid naming configuration in '$key'."
        }
        if (-not $record.validation_complete -and $record.validation_notes.Count -eq 0) {
            throw "Incomplete validation in '$key' requires an explanation."
        }
    }
    return $catalog
}

function Write-NamingCatalog {
    [CmdletBinding(SupportsShouldProcess)]
    param([System.Collections.IDictionary] $Catalog, [string] $Path)

    $json = ConvertTo-NamingCatalogJson $Catalog
    $null = ConvertFrom-NamingCatalogJson $json
    if ([System.IO.File]::Exists($Path) -and [System.IO.File]::ReadAllText($Path) -ceq $json) { return $false }
    if ($PSCmdlet.ShouldProcess($Path, 'Write validated naming catalog')) {
        $temporary = "$Path.$([guid]::NewGuid().ToString('N')).new"
        try {
            [System.IO.File]::WriteAllText($temporary, $json, [System.Text.UTF8Encoding]::new($false))
            [System.IO.File]::Move($temporary, $Path, $true)
        }
        finally {
            if ([System.IO.File]::Exists($temporary)) { [System.IO.File]::Delete($temporary) }
        }
        return $true
    }
    return $false
}

function ConvertTo-ResourceNameCatalog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $RulesMarkdown,
        [Parameter(Mandatory)][string] $AbbreviationsMarkdown,
        [Parameter(Mandatory)][System.Collections.IDictionary] $Manual,
        [AllowNull()][System.Collections.IDictionary] $Previous
    )

    $rules = ConvertFrom-ResourceNameRulesMarkdown $RulesMarkdown
    $abbreviations = ConvertFrom-ResourceAbbreviationsMarkdown $AbbreviationsMarkdown
    $sectionNotes = Get-NamingSectionNote $RulesMarkdown
    $groups = [System.Collections.Generic.Dictionary[string, object]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($rule in $rules.Values) {
        $type = Resolve-NamingResourceType $rule.resource_type
        if ($groups.ContainsKey($type)) { throw "Source corrections produced duplicate naming rules for '$type'." }
        $groups[$type] = @{ resource_type = $type; rule = $rule; abbreviations = [System.Collections.Generic.List[object]]::new() }
    }
    foreach ($row in $abbreviations) {
        if (-not $groups.ContainsKey($row.resource_type)) {
            $groups[$row.resource_type] = @{ resource_type = $row.resource_type; rule = $null; abbreviations = [System.Collections.Generic.List[object]]::new() }
        }
        $group = $groups[$row.resource_type]
        $namespace = ($group.resource_type -split '/')[0]
        $entity = $row.resource_type.Substring($row.resource_type.IndexOf('/') + 1)
        $group.resource_type = "$namespace/$entity"
        $group.abbreviations.Add($row)
    }
    $mappings = if ($Manual.Contains('legacy_mappings')) { $Manual.legacy_mappings } else { [ordered]@{} }
    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($typeKey in (Get-NamingRulesSortedKey $groups)) {
        $group = $groups[$typeKey]
        $type = $group.resource_type
        $baseKey = ConvertTo-NamingTerraformKey $type
        $namespace = ($type -split '/')[0].ToLowerInvariant()
        $notes = @()
        if ($sectionNotes.ContainsKey($namespace)) { $notes = @($sectionNotes[$namespace].ToArray()) }
        $runtime = ConvertTo-NamingRuntimeRule -Rule $group.rule -SectionNotes $notes
        $variants = [ordered]@{}
        foreach ($row in $group.abbreviations) {
            $variant = Get-NamingAbbreviationVariant $row ($group.abbreviations.Count -gt 1)
            $id = if ($null -eq $variant -or $variant -eq '') { '__base' } else { $variant }
            if ($variants.Contains($id)) {
                if ($variants[$id].abbreviation -cne $row.abbreviation) {
                    throw "Conflicting abbreviation recommendations for '$type' variant '$id'."
                }
                continue
            }
            $variants[$id] = @{
                variant = $variant; abbreviation = $row.abbreviation
                legacy_slug = $null; legacy_outputs = [System.Collections.Generic.List[string]]::new()
            }
        }
        if ($variants.Count -eq 0) {
            $variants['__base'] = @{ variant = $null; abbreviation = $null; legacy_slug = $null; legacy_outputs = [System.Collections.Generic.List[string]]::new() }
        }
        foreach ($alias in $mappings.Keys) {
            $mapping = $mappings[$alias]
            if ($null -eq $mapping.resource_type -or
                (Resolve-NamingResourceType $mapping.resource_type) -ine $type) { continue }
            $slugMatches = @($variants.Keys | Where-Object { $null -ne $variants[$_].abbreviation -and $variants[$_].abbreviation -ceq $mapping.slug })
            $requested = if ($null -eq $mapping.variant -or $mapping.variant -eq '') { '__base' } else { ConvertTo-NamingSnakeCase $mapping.variant }
            $id = if ($variants.Contains($requested)) { $requested } elseif ($slugMatches.Count -eq 1) { $slugMatches[0] } else { $requested }
            if ($variants.Contains($id) -and $null -ne $variants[$id].legacy_slug -and $variants[$id].legacy_slug -cne $mapping.slug) {
                $id = ConvertTo-NamingSnakeCase $alias
            }
            if (-not $variants.Contains($id)) {
                $variants[$id] = @{
                    variant = if ($id -eq '__base') { $null } else { $id }
                    abbreviation = $null; legacy_slug = $null; legacy_outputs = [System.Collections.Generic.List[string]]::new()
                }
            }
            $variants[$id].legacy_slug = $mapping.slug
            $variants[$id].legacy_outputs.Add($alias)
        }
        foreach ($variantInfo in $variants.Values) {
            $key = $baseKey + $(if ($null -ne $variantInfo.variant) { "_$($variantInfo.variant)" } else { '' })
            $record = [ordered]@{
                resource_type = $type; variant = $variantInfo.variant
                slug = $variantInfo.abbreviation; slug_source = if ($null -eq $variantInfo.abbreviation) { 'derived' } else { 'caf' }
                legacy_slug = $variantInfo.legacy_slug
                legacy_outputs = @($variantInfo.legacy_outputs | Sort-Object -CaseSensitive)
            }
            foreach ($field in $runtime.Keys) { $record[$field] = $runtime[$field] }
            $record.source = [ordered]@{
                naming_rules_url = Get-ResourceNameRulesSourceUrl
                naming_rule = $group.rule
                section_notes = $notes
                abbreviations_url = $script:AbbreviationsUrl
                abbreviations = @($group.abbreviations.ToArray())
            }
            $candidates.Add(@{ key = $key; record = $record; manual = $false })
        }
    }

    $manualRecords = [ordered]@{}
    foreach ($key in $Manual.resources.Keys) {
        $record = $Manual.resources[$key]
        if ($null -ne $record.resource_type -and $groups.ContainsKey((Resolve-NamingResourceType $record.resource_type))) { continue }
        $manualRecords[$key] = $record
    }
    if ($null -ne $Previous) {
        foreach ($key in $Previous.resources.Keys) {
            $record = $Previous.resources[$key]
            if ($null -ne $record.resource_type -and -not $groups.ContainsKey((Resolve-NamingResourceType $record.resource_type))) {
                if (-not $manualRecords.Contains($key)) {
                    $copy = [ordered]@{}
                    foreach ($field in $record.Keys) { $copy[$field] = $record[$field] }
                    $copy.source = [ordered]@{ status = 'removed_from_selected_sources'; previous = $record.source }
                    $copy.slug_source = 'manual'
                    $manualRecords[$key] = $copy
                }
            }
        }
    }
    foreach ($key in $manualRecords.Keys) {
        $record = $manualRecords[$key]
        $copy = [ordered]@{}
        foreach ($field in $record.Keys) { $copy[$field] = $record[$field] }
        $candidates.Add(@{ key = $key; record = $copy; manual = $true })
    }

    $collisions = @($candidates | Group-Object { $_.key } | Where-Object Count -gt 1)
    foreach ($collision in $collisions) {
        foreach ($candidate in $collision.Group) {
            if ($null -eq $candidate.record.resource_type) { throw "Cannot provider-qualify a non-ARM key collision: $($collision.Name)" }
            $provider = ($candidate.record.resource_type -split '/')[0] -replace '^[^.]+\.', ''
            $provider = $provider -creplace '^DBfor', 'DBFor'
            $candidate.key = (ConvertTo-NamingSnakeCase $provider) + '_' + $candidate.key
        }
    }
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $aliases = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $generated = [ordered]@{
        schema_version = 2
        sources = @((Get-ResourceNameRulesSourceUrl), $script:AbbreviationsUrl)
        resources = [ordered]@{}
    }
    $manualResult = [ordered]@{}
    foreach ($field in $Manual.Keys) { $manualResult[$field] = $Manual[$field] }
    $manualResult.schema_version = 2
    $manualResult.resources = [ordered]@{}
    foreach ($candidate in ($candidates | Sort-Object { $_.key } -CaseSensitive)) {
        $key = $candidate.key
        if (-not $seen.Add($key)) { throw "Terraform key collision remains after provider qualification: $key" }
        $record = $candidate.record
        if ($record.slug_source -eq 'derived') {
            $record.slug = if ($record.dashes) { $key.Replace('_', '-') } else { $key.Replace('_', '') }
        }
        foreach ($alias in $record.legacy_outputs) {
            if (-not $aliases.Add($alias)) { throw "Legacy output '$alias' is assigned more than once." }
        }
        if ($candidate.manual) { $manualResult.resources[$key] = $record }
        else { $generated.resources[$key] = $record }
    }
    foreach ($alias in $mappings.Keys) {
        if (-not $aliases.Contains($alias)) { throw "Legacy mapping '$alias' is not assigned to a catalog entry." }
    }
    $null = ConvertFrom-NamingCatalogJson (ConvertTo-NamingCatalogJson $generated)
    $null = ConvertFrom-NamingCatalogJson (ConvertTo-NamingCatalogJson $manualResult)
    return [pscustomobject]@{ Generated = $generated; Manual = $manualResult; CollisionCount = $collisions.Count }
}

function Update-ResourceNameCatalog {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $RulesMarkdown,
        [Parameter(Mandatory)][string] $AbbreviationsMarkdown,
        [Parameter(Mandatory)][string] $GeneratedPath,
        [Parameter(Mandatory)][string] $ManualPath
    )

    $manual = ConvertFrom-NamingCatalogJson ([System.IO.File]::ReadAllText($ManualPath))
    $previous = if ([System.IO.File]::Exists($GeneratedPath)) {
        ConvertFrom-NamingCatalogJson ([System.IO.File]::ReadAllText($GeneratedPath))
    } else { $null }
    $result = ConvertTo-ResourceNameCatalog -RulesMarkdown $RulesMarkdown -AbbreviationsMarkdown $AbbreviationsMarkdown -Manual $manual -Previous $previous
    $changed = [System.Collections.Generic.List[string]]::new()
    if ($PSCmdlet.ShouldProcess("$GeneratedPath; $ManualPath", 'Regenerate runtime naming catalogs')) {
        if (Write-NamingCatalog $result.Generated $GeneratedPath -Confirm:$false) { $changed.Add($GeneratedPath) }
        if (Write-NamingCatalog $result.Manual $ManualPath -Confirm:$false) { $changed.Add($ManualPath) }
    }
    return [pscustomobject]@{
        Changed = $changed.Count -gt 0
        ChangedFiles = $changed.ToArray()
        GeneratedCount = $result.Generated.resources.Count
        ManualCount = $result.Manual.resources.Count
        QualifiedCollisionGroups = $result.CollisionCount
    }
}

Export-ModuleMember -Function Get-ResourceAbbreviationsSourceUrl, ConvertTo-NamingSnakeCase,
    ConvertTo-NamingTerraformKey, Resolve-NamingResourceType, ConvertFrom-ResourceAbbreviationsMarkdown,
    Get-NamingSectionNote, ConvertTo-NamingRuntimeRule, Get-NamingAbbreviationVariant,
    ConvertTo-NamingCatalogJson, ConvertFrom-NamingCatalogJson, Write-NamingCatalog,
    ConvertTo-ResourceNameCatalog, Update-ResourceNameCatalog
