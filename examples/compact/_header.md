# Compact naming templates

Hashes only the workload prefix/suffix into eight hexadecimal characters. The complete formatted `instance` and `unique` tokens are interpolated directly; neither is hashed or sliced.

The catalog's separator keeps the same recipe usable for resource groups and storage accounts. A supplied seed makes the result repeatable without random resources. Hashing workload text does not check Azure name availability or guarantee collision-free names.
