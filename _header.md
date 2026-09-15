# Azure Verified Naming Utility

Generate Azure resource names from JSON catalogs. Requires Terraform 1.9 or later. This utility creates no Azure resources and requires no Azure credentials.

```hcl
module "naming" {
  source = "Azure/avm-utl-naming/azure"

  suffix = ["workload", "dev"]
}
```

Use `module.naming.names.storage_account.name_unique` or `module.naming.names_by_azure_type["Microsoft.Storage/storageAccounts"].storage_account.name_unique`.

## Modern catalogs and manual corrections

- `data/resource-name-rules.json` is generated from Microsoft's [naming rules](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules) and [CAF abbreviations](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).
- `data/resource-name-rules.manual.json` contains additions and property overrides in the same `resources` map, plus compatibility mappings and persisted public-key assignments. Original slugs fill gaps where the selected sources have no unambiguous CAF abbreviation; documented CAF recommendations remain the default.

Both resource maps use snake-case keys, with distinct entries for variants such as web apps and function apps. Key generation happens in PowerShell. Existing keys are retained when new types collide; only new entries are qualified. `names_by_azure_type` groups entries into maps using the same keys. Non-ARM manual entries appear only in `names`.

Catalogs merge in order: **generated, then bundled manual, then customer file**. Each layer can add keys or override individual properties of an existing key. For example, this manual or customer file changes only the static-site maximum:

```json
{
  "schema_version": 2,
  "resources": {
    "static_site": {
      "max_length": 30
    }
  }
}
```

Omitted properties and unrelated keys survive the merge. Supplied properties replace their previous values, including `false`, `0`, `""`, and nullable constraints set to `null`. Arrays and nested metadata objects replace as whole properties; this is not an arbitrary recursive JSON merge. Bundled corrections retain provenance in `override_reason` and `override_source`. Generated source data is unchanged.

### Customer override file

```hcl
module "naming" {
  source = "Azure/avm-utl-naming/azure"

  custom_override_file = "${path.module}/naming-overrides.json"
}
```

See [the customer-file example](examples/customer_overrides) for a partial slug override, an overridden manual limit, and a new storage-account variant. The file is caller-owned, not another bundled catalog. It must exist before Terraform starts; relative paths resolve from the Terraform working directory.

New keys require a string `slug` (empty omits it). Optional fields default to unknown constraints, lowercase separator-free names, and incomplete validation. Set `resource_type` and a distinct `variant` to expose a variant in the Azure-type view. Lengths, regexes, scope, `dashes`, `lowercase`, `name_kind`/`fixed_name`, and validation settings use the same properties as the bundled catalogs. String-array properties are `validation_notes`, `forbidden_prefixes`, `forbidden_suffixes`, `forbidden_sequences`, and `reserved_names`; clear an array with `[]`, not `null`.

Invalid keys, property names/types, naming modes, regexes, and reversed bounds are rejected. `slug_overrides` takes precedence over every file. Customer `legacy_outputs` metadata cannot reassign deprecated aliases; their membership comes from the bundled catalogs.

Missing constraints remain null unless an override supplies them. Clearing a bound or regex also makes validation incomplete, even if `validation_complete = true` was inherited. Incomplete modern validation returns null flags with `validation_notes`; these are candidate names, not verified Azure names. Name availability is not checked.

## Naming templates

Modern mode defaults to the familiar prefix, slug, suffix, and uniqueness pattern, using the entry's separator and casing rules. Override the convention with escaped `$${token}` expressions.

In HCL string inputs, the extra `$` in `$${token}` passes literal `${token}` to this module's `templatestring` call instead of resolving it in the caller. Without escaping, module tokens such as `slug` can cause invalid-reference validation errors before the module evaluates the template.

```hcl
naming_template_variables = {
  environment = "prod"
  location    = "uks"
}
naming_templates = {
  name        = "$${join(separator, compact([slug, environment, location]))}"
  name_unique = "$${join(separator, compact([unique, name]))}"
}
```

Built-in tokens are `prefix` and `suffix` lists, `slug`, `separator`, `unique`, `unique_seed`, `terraform_key`, `resource_type`, `variant`, `min_length`, and `max_length`. The unique template also receives `name`, with space reserved for the template's overhead. Custom string tokens cannot replace built-in tokens.

The default unique template preserves the uniqueness token when truncating. Custom unique templates must interpolate the complete `unique` token directly or through a case conversion such as `upper(unique)`. Token-aware probe rendering distinguishes interpolation from a coincidental match in a prefix. Arbitrary hashing, slicing, or conditional transformations are not claimed to preserve the complete token.

Feasibility is per entry: an oversized or unverifiable unique name returns `name_unique = null`, `name_unique_available = false`, and explanatory `name_unique_errors`. Other entries remain usable. `fits_max_length` describes the unique-name candidate and is null when no maximum is known. Check the selected entry before using it:

```hcl
output "storage_account_name" {
  value = module.naming.names.storage_account.name_unique

  precondition {
    condition     = module.naming.names.storage_account.name_unique_available
    error_message = join(" ", module.naming.names.storage_account.name_unique_errors)
  }
}
```

Entries also expose `unique_suffix_retained`. Literal names remain fixed; GUID-only names use deterministic UUID rendering. For Windows consumers whose `computer_name` defaults to the resource name, use `names.virtual_machine_windows` (15-character cap) instead of the generic 64-character ARM-name entry.

`slug_overrides` is a nullable map keyed by the JSON key. An empty override omits the slug.

## Migrating from the original module

For original behavior, keep the existing module block name, input values, and Terraform state; change the source and add `legacy_mode = true`:

```hcl
module "naming" {
  source = "Azure/avm-utl-naming/azure"

  legacy_mode = true
  prefix      = ["Contoso"]
  suffix      = ["Prod"]
}

output "resource_group_name" {
  value = module.naming.resource_group.name
}
```

Run `terraform init -upgrade` and inspect the plan. Keep any existing seed and uniqueness-length configuration unchanged. Both original random-resource addresses are retained.

Legacy mode uses the frozen [original renderer](https://github.com/Azure/terraform-azurerm-naming/tree/fc289126c9c888393ff02a79e1babadd6865861c) in `locals.legacy.tf`, not the current JSON rules. It retains original separators, casing, per-alias limits, regexes, scope tokens, and boolean validation, including historical quirks. Continue using the deprecated named outputs in `outputs.legacy.tf`; the modern dynamic maps are empty in this mode. Modern templates, custom tokens, slug overrides, bundled rule patches, and customer files do not change legacy results.

See [the override-free legacy example](examples/legacy). `legacy_mode` defaults to false. Modern mode can produce different names, so switching modes is a deliberate migration. The legacy code is temporary; pin a module version if you need it after its removal.

### Deprecated input names

| Deprecated input | Replacement |
| --- | --- |
| `unique-include-numbers` | `unique_include_numbers` |
| `unique-length` | `unique_length` |
| `unique-seed` | `unique_seed` |

The old inputs remain in `variables.deprecated.tf`. A non-null replacement takes precedence in either mode; null uses the deprecated input. Effective defaults remain `true`, `4`, and a state-persisted random seed. Explicit `false`, `0`, and empty `unique_seed` values are honored.

## Updates

The Monday 06:23 UTC/manual workflow regenerates modern runtime data and proposes changes for review. It never updates the frozen legacy renderer or automatically merges changes. An open update is left untouched until merged or closed.

Manual additions, property overrides, and public-key assignments persist across regeneration, including when an entry becomes documented. Removed generated entries are retained beneath any existing manual patch so omitted properties are not lost.

Repository settings must permit GitHub Actions to create pull requests. Requests created with `GITHUB_TOKEN` do not automatically trigger other workflows; validation runs before publication.
