# Azure Verified Naming Utility

JSON-backed Azure resource names, compatible with `Azure/naming/azurerm`. Requires Terraform 1.9 or later. This utility creates no Azure resources, requires no Azure credentials, and collects no telemetry.

```hcl
module "naming" {
  source = "Azure/avm-utl-naming/azurerm"

  suffix = ["workload", "dev"]
}
```

Use `module.naming.resource_group.name` or `module.naming.storage_account.name_unique`. The `names` output also exposes the complete catalog as a map.

## Compatibility

The five original inputs, including the hyphenated `unique-*` inputs, and all 300 original outputs are retained. Keep the same module block name when changing the source and run `terraform init -upgrade`. The `random_string.main` and `random_string.first_letter` state addresses are unchanged, preserving existing random seeds.

Names retain the original slugs, separators, casing, truncation, and validation behavior. Maximum-length truncation can remove the uniqueness suffix. `validation` reports the legacy regex checks, not name availability or a guarantee of Azure acceptance.

Definitions live in `resourceDefinition.json` and `resourceDefinition_out_of_docs.json`; no code-generation step is required. Regexes use Terraform's RE2 syntax and may reference `min_length` and `max_length` through `templatestring`. New definitions are immediately available through `names`; the existing named outputs are static compatibility aliases.

## Naming rule updates

The update workflow checks [Microsoft's naming rules](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/azure-resource-manager/management/resource-name-rules.md) every Monday at 06:23 UTC and supports manual dispatch. It proposes additions to `data/resource-name-rules.json` on the stable `automation/resource-name-rules-additions` branch, without changing or removing existing entries.

The inventory preserves documented entities, including data-plane shorthand; it is not a validated ARM schema. Reviewers add accepted naming definitions to the runtime JSON catalogs. Existing names, slugs, and regexes are never changed automatically.

Repository settings must allow GitHub Actions to create pull requests. The workflow runs its own checks; requests created with `GITHUB_TOKEN` do not automatically trigger other workflows. No additional credentials or Azure access are required.
