# Naming templates example

The original `naming` module uses `join` and `compact` to compose custom environment/location tokens and place uniqueness first. Its outputs remain `abcd-rg-dev-uks` and `abcdstdevuks`.

Two additional modules demonstrate direct interpolation without functions. Both set numeric `instance = 1`; the naming module formats the built-in `$${instance}` token as `001` using the default `instance_format = "%03d"`.

```hcl
name = "$${slug}-$${environment}-$${location}-$${instance}"
```

`naming_template_variables` supplies only `environment = "dev"` and `location = "uks"`. The `literal_template` module produces `rg-dev-uks-001` for a resource group.

Literal hyphens are not valid for every resource. The `separator_aware` module uses `$${separator}` instead of `-`, producing `stdevuks001` for a storage account.

The additional modules set `unique_length = 0` and leave `name_unique` unspecified. Change `instance_format` to override the module's formatting; no manually padded string or inline formatting function is needed.

When supplying a template as an HCL string input, `$${token}` escapes caller-side interpolation and passes literal `${token}` to this module's `templatestring` call. Without escaping, Terraform can fail validation while trying to resolve module tokens such as `slug` in the calling configuration.
