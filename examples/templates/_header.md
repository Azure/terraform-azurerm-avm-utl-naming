# Naming templates example

Start with a template that reads like the name you want:

```hcl
name = "$${slug}-$${environment}-$${location}-$${sequence}"
```

`naming_template_variables` supplies `environment = "dev"`, `location = "uks"`, and `sequence = "001"`. The module supplies the resource's `slug`, producing `rg-dev-uks-001` for a resource group.

Literal hyphens are not valid for every resource. The second module uses `$${separator}` instead of `-`, producing `stdevuks001` for a storage account without calling any functions.

This introductory example sets `unique_length = 0`. Leaving `name_unique` unspecified uses the module's default behavior, including handling an empty uniqueness token without a trailing separator.

`sequence` is a custom string token here. For module-managed numeric formatting and instance retention, set `instance = 1` and use `$${instance}` instead; its default formatted value is `001`.

When supplying a template as an HCL string input, `$${token}` escapes caller-side interpolation and passes literal `${token}` to this module's `templatestring` call. Without escaping, Terraform can fail validation while trying to resolve module tokens such as `slug` in the calling configuration.
