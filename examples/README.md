# Modern naming examples

These examples generate names without deploying Azure resources or requiring Azure credentials.

| Example | Purpose |
| --- | --- |
| [Default](default) | Workload/environment affixes and a state-persisted uniqueness token. |
| [Seeded](seeded) | Repeatable names with a supplied seed and slug override. |
| [Templates](templates) | Custom tokens and a uniqueness-first convention. |
| [Compact](compact) | Short workload hashes while retaining complete instance/unique tokens. |
| [Instances](instances) | Twenty numbered instances without randomness. |
| [Customer overrides](customer_overrides) | Partial catalog overrides and an additional modern variant. |

Author each example in Terraform and `_header.md`; generate its README with `avm docs`. See the [contribution guide](../docs/contributing.md) for checks and editable files.
