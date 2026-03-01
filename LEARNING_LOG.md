# Learning Log

## 2026-02-22

1. Class `static` variables in Apex are scoped to a single execution context (transaction). They persist across triggers and code units in that transaction, then reset in the next transaction.
2. We cannot guarantee that seeing an `AFTER_*` trigger event means the execution context has ended. Additional platform code can still run before the transaction fully finishes.
