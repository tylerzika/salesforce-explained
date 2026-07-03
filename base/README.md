# base

Shared foundation package for the reference packages in this repo (`sales`, future `service`, …). Dependent packages declare a dependency on `base` in `sfdx-project.json`; it always installs first.

## Contents

Vendored copy of the **Trigger Actions Framework** by Mitch Spano:

- Upstream: https://github.com/mitchspano/trigger-actions-framework
- Vendored at upstream commit `5c3793d` (framework version 0.3.x), 2026-07-03
- License: Apache 2.0 (see `LICENSE` in this directory; upstream copyright headers retained in source)

The framework provides metadata-driven trigger dispatch: one trigger per object calls `TriggerBase`/`MetadataTriggerHandler`, which reads `Trigger_Action__mdt` custom metadata records and dynamically instantiates the registered `TriggerAction.*` implementations. Dependent packages ship their own handler classes and `Trigger_Action__mdt` records — `base` never references code in the packages that depend on it (dependency inversion at packaging scale).

## Why vendored instead of depending on the upstream package

Recorded as decision D3 on the Artifact A wiki page (Second Brain vault). Short version: self-contained install chain (no third-party 04t in every org), full control over versioning and source API level, and the framework is small enough (~15 production classes) to track upstream by manual diff against the pinned commit.

## Local changes from upstream

None yet. Keep this section updated if the vendored source ever diverges — upgrades are done by diffing upstream against commit `5c3793d`.
