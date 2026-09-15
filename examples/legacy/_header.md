# Legacy migration example

Runs the frozen original naming implementation. Keep the existing module block name, prefix/suffix, uniqueness inputs, and state when changing module sources; add `legacy_mode = true` and continue using the deprecated resource outputs.

Modern naming templates and slug overrides are ignored in this mode. The dynamic output maps are empty. This example deliberately has no slug override.
