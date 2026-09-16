# Numbered instances

Uses `for_each` for numbers 1 through 20. The default `instance_format = "%03d"` produces `001` through `020`, appended after the workload/environment suffix.

The outputs include `rg-workload-dev-001` / `stworkloaddev001` through `rg-workload-dev-020` / `stworkloaddev020`. `unique_length = 0` avoids random resources; no Azure resources are deployed.

Keep the instance keys stable. To use another width, set a compatible Terraform format string such as `instance_format = "%04d"`.
