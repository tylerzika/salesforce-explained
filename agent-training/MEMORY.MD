# Long-Term Memory (Main Session Only)

## Identity and Model
- Primary assistant identity: Horymir (The Spirit of CRM).
- Active model log:
  - 2026-02-22: GPT-5 (Codex).

## About Jim in Sales
- Jim is a software engineer/operator with strong architecture instincts.
- He learns effectively from transaction logs, empirical runtime behavior, and direct code changes.
- He prefers practical execution and fast iteration over speculative design work.
- He values concept bridges from classic CS texts to Salesforce platform mechanics.

## Durable Collaboration Preferences
- Keep explanations concrete, with file-level references and production relevance.
- Use instrumentation and tests to explain behavior (especially triggers and transaction boundaries).
- Treat agent memory files as first-class artifacts and keep them current.
- When AI capabilities open a much larger design space, help compress that space into a few strong abstractions rather than enumerating every possibility.

## Durable Technical Themes
- Apex class static variables are transaction-scoped and persist across trigger invocations in the same execution context.
- Trigger orchestration should stay thin; domain behavior belongs in handlers/services.
- External-ID upsert scripts are useful for deterministic, repeatable debugging scenarios.
- CLRS-style invariants are effective for proving trigger instrumentation behavior (for example, monotonic `logCalls` and per-object counters within one transaction).
- `AFTER_*` trigger events are not a transaction-end oracle; additional platform code units can still execute before `EXECUTION_FINISHED`.
- Models API inside Apex is best treated as a hybrid-systems primitive: Apex owns law, state, validation, and side effects; the model owns ambiguous interpretation, drafting, summarization, and heuristic compression.
- Chat-first service boundaries are a better long-term abstraction than scattering raw prompt strings through the codebase.
- Jim is energized by the idea that Apex + LWC + built-in models turns Salesforce into a vertically integrated programming medium, not just a CRUD platform.
- TAOCP and SICP references are effective framing devices for this work: TAOCP for representation, control, and measurement; SICP for abstraction barriers and environment models.
- The named third conceptual lane is `Symbolic Transformation`: treating prompts, schemas, evidence packets, and model outputs as operational symbolic artifacts rather than low-status "just strings."
