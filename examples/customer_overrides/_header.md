# Customer naming overrides

Pass a caller-local JSON file with `custom_override_file = "${path.module}/naming-overrides.json"`.

This example replaces the database-account slug and the static-site maximum while retaining their other bundled properties. It also adds an internal storage-account variant, available through both dynamic outputs. The file merges after the generated and bundled manual catalogs; it does not change legacy mode. No Azure resources are deployed.
