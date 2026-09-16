# Contributing naming changes

Use PowerShell 7.4 or later and [Avm.Authoring](https://azure.github.io/Azure-Verified-Modules/contributing/terraform/terraform-contribution-flow/). The native catalog/schema checks and naming examples need no Azure resources or credentials.

## Choose the source

| Files | Purpose |
| --- | --- |
| `data/resource-name-rules.json` | Generated from Microsoft naming rules and CAF abbreviations; do not edit by hand. |
| `data/resource-name-rules.manual.json` | Modern additions and property overrides, with source/reason metadata. |
| `scripts/ResourceNameCatalog.psm1`, `scripts/ResourceNameRules.psm1` | Source parsing and catalog generation. |
| `schemas/*.json` | Structural editor validation for complete catalogs and partial overlays. |
| Modern Terraform files and `tests/unit` | Rendering, interfaces, and focused regression cases. Leave frozen legacy files unchanged. |
| `_header.md`, example `_header.md` files, `docs/` | Authored documentation. Module/example READMEs are generated; preserve standard footers. |

Keep public catalog keys stable. Overlay only the properties being corrected; omitted fields retain their previous values. Include the relevant Microsoft source and add a focused parser or Terraform regression case. Name changes can replace consumer resources even when the change corrects a rule.

`CONTRIBUTING.md`, shared configuration, and standard footers belong to the AVM managed baseline. Do not replace them with module-specific instructions. The static `examples/README.md` landing page is source-owned; it is not a Terraform documentation target.

## Check catalog changes

Only refresh the upstream catalog when working on catalog/source changes:

```powershell
.\scripts\Update-ResourceNameRules.ps1
.\scripts\tests\Test-ResourceNameRules.ps1
.\scripts\tests\Test-NamingSchemas.ps1
```

The update command changes the generated and bundled manual catalogs. Inspect both diffs. For offline source input, supply `-DocumentPath` and `-AbbreviationsDocumentPath`. The parser/publication tests mock publication; do not run `Publish-ResourceNameRules.ps1` locally.

Use `schemas/naming-catalog.schema.json` for generated full entries and `schemas/naming-overrides.schema.json` for partial bundled/customer files. The catalogs, customer example, and representative fixture carry relative `$schema` annotations that editors can resolve without changing managed VS Code settings. Catalog generation emits these references, so editor support survives regeneration and AVM synchronization. The schema tests require the annotations and validate through their resolved paths.

For caller-owned JSON elsewhere, add a `$schema` reference to its local or published override schema, or configure the caller's editor. Keep both schema files together when copying them: the generated-catalog schema references the override schema. An annotation is not required by the Terraform interface. Schemas do not evaluate cross-file inheritance, bound ordering, or Terraform RE2/templates; a schema pass is not runtime validation.

## Check the module and documentation

```powershell
Import-Module Avm.Authoring
avm version
avm test unit
avm pre-commit
```

For documentation-only changes, `avm docs` regenerates the module and individual example READMEs. `avm pre-commit` also synchronizes managed files and applies formatting/conventions. Review generated changes rather than editing those READMEs directly. Do not use the retired Go, Make, or repository-launcher commands.

After committing the complete worktree, run `avm pr-check`. Follow [AVM versioning](https://azure.github.io/Azure-Verified-Modules/spec/SNFR17) and describe any effect on existing modern names.
