# Naming templates example

Uses escaped `$${token}` interpolation, custom string tokens, and a uniqueness-first template. Built-in tokens include the resource's slug and separator, so the same convention works for dashed and separator-free names.

When supplying a template as an HCL string input, `$${token}` escapes caller-side interpolation and passes literal `${token}` to this module's `templatestring` call. Without escaping, Terraform can fail validation while trying to resolve module tokens such as `slug` in the calling configuration.
