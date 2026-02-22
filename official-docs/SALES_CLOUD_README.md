# Sales Cloud Context (Spring '26)

## Workspace Notes
- See `official-docs/NOTES_AND_SUGGESTIONS.md` for local implementation notes, doc usage guidance, and suggested additions.

## Source and Freshness
- Source file: `sales_core_extracted.txt`
- Source document: Salesforce Sales Cloud Basics, Spring '26
- Source last-updated marker: November 17, 2025
- Context boundary: This file is a working context layer derived from extracted text; verify release-sensitive details against current Salesforce Help before implementation.

## How to Use This File (for Agent Context)
- Use this file first for orientation, vocabulary, and feature-to-task mapping.
- Then use `sales_core_extracted.txt` for deep lookup with targeted keyword search.
- Prompt pattern: `Identify the relevant capability block, then list setup surfaces, constraints, and next checks.`
- Query pattern: `feature lookup` -> `section map` -> `capability block` -> `retrieval cues` -> `source text validation`.

## Executive Context in 60 Seconds
Sales Cloud is the Salesforce domain for lead-to-revenue execution: campaign attribution, pipeline management, account/contact management, territory and forecasting operations, seller workflows, and AI-assisted selling.

Primary capability domains in this extract:
- Implementation readiness and rollout guidance
- Seller Home and productivity surfaces
- Personal Labels for user-level record organization
- Campaign strategy, setup, hierarchy, members, and influence
- Opportunity lifecycle, pricing, quotes, products, and related automation
- Account/contact data model and relationship management
- Mapping and routing with Salesforce Maps Lite
- Team management: forecasting, territories, splits, process guidance
- AI and Einstein features in sales workflows
- Digital engagement channels inside Sales Console/Sales Engagement

Typical admin/ops goals this context supports:
- Standardize lead and opportunity processes
- Improve campaign ROI visibility and attribution quality
- Strengthen account/contact data governance
- Improve forecast quality and territory coverage
- Increase rep productivity with guided workspace and automation

## Section Map (Fast Navigation)
- [Sales Cloud Basics](#sales-cloud-basics)
- [Learn About, Implement, and Optimize Sales Cloud Features (p.2)](#learn-about-implement-and-optimize-sales-cloud-features-p2)
- [See an Overview of Metrics, Goals, Suggestions, Tasks, and Activities in Seller Home (p.4)](#see-an-overview-of-metrics-goals-suggestions-tasks-and-activities-in-seller-home-p4)
- [Organize and Find Records Easily with Personal Labels (p.5)](#organize-and-find-records-easily-with-personal-labels-p5)
- [Capture ROI with Campaigns (p.7)](#capture-roi-with-campaigns-p7)
- [Turn Opportunities into Deals (p.114)](#turn-opportunities-into-deals-p114)
- [Manage Accounts and Contacts (p.202)](#manage-accounts-and-contacts-p202)
- [Showing Customers and Prospects on a Map (p.299)](#showing-customers-and-prospects-on-a-map-p299)
- [Manage a Sales Team (p.302)](#manage-a-sales-team-p302)
- [Artificial Intelligence and Sales Cloud (p.572)](#artificial-intelligence-and-sales-cloud-p572)
- [Digital Engagement for Sales Cloud (p.588)](#digital-engagement-for-sales-cloud-p588)
- [More Sales Features (p.590)](#more-sales-features-p590)
- [Resources for the Sales Professional (p.596)](#resources-for-the-sales-professional-p596)

## Capability Blocks (Agent-First)

### Sales Cloud Basics
- Purpose: Frame Sales Cloud as the operating system for sales execution from lead generation to forecast and team performance.
- Key objects/entities: Leads, Opportunities, Accounts, Contacts, Campaigns, Forecasting entities, Territories.
- Core workflows: Generate leads, progress pipeline, manage relationships, forecast revenue, organize selling teams.
- Common setup surfaces: Org-level Sales Cloud setup, object configuration, permissions, process definitions.
- Typical pitfalls/constraints: Process misalignment across teams, incomplete data foundations, over-customization before baseline adoption.
- Retrieval cues: `SALES CLOUD BASICS`, `sales pipeline`, `forecast revenues`, `selling teams`.

### Learn About, Implement, and Optimize Sales Cloud Features (p.2)
- Purpose: Provide rollout and maturity guidance for implementing core Sales Cloud capabilities.
- Key objects/entities: Reports, Dashboards, Accounts, Contacts, Leads, Opportunities, Users.
- Core workflows: Assess readiness, configure core features, enable users, optimize over time.
- Common setup surfaces: User management, reporting configuration, data visibility/access, adoption strategy assets.
- Typical pitfalls/constraints: Skipping rollout planning, weak change management, under-investing in reporting design.
- Retrieval cues: `rollout strategy`, `configure`, `reports and dashboards`, `user training`, `health check`.

### See an Overview of Metrics, Goals, Suggestions, Tasks, and Activities in Seller Home (p.4)
- Purpose: Centralize rep daily execution with KPI, goal, task, and activity visibility.
- Key objects/entities: Seller Home widgets, Goals, Tasks/To Do items, Activities, Einstein suggestions.
- Core workflows: Daily prioritization, goal tracking, task execution, recent-record navigation.
- Common setup surfaces: Lightning Home configuration, component placement, user profile/permission alignment.
- Typical pitfalls/constraints: Misconfigured home layouts, irrelevant widgets, missing user enablement.
- Retrieval cues: `Seller Home`, `goals`, `suggestions`, `agenda`, `to-do items`.

### Organize and Find Records Easily with Personal Labels (p.5)
- Purpose: Allow users to apply personal metadata labels for quick record organization and retrieval.
- Key objects/entities: Personal labels, labeled records, My Labels component.
- Core workflows: Add labels, search/filter by labels, manage personal record groupings.
- Common setup surfaces: Record page layout/component configuration by admins.
- Typical pitfalls/constraints: Confusing personal labels with org-wide taxonomy; inconsistent labeling practices.
- Retrieval cues: `Personal Labels`, `My Labels component`, `organize records`, `find records quickly`.

### Capture ROI with Campaigns (p.7)
- Purpose: Track marketing performance and revenue influence through campaign structures and member engagement.
- Key objects/entities: Campaign, Campaign Member, Campaign Hierarchy, Campaign Influence, Primary Campaign Source.
- Core workflows: Define campaign types/statuses, add members, link opportunities, report on influence and ROI.
- Common setup surfaces: Campaign object configuration, marketing user permissions, status/type setup, hierarchy configuration.
- Typical pitfalls/constraints: Poor hierarchy design, inconsistent member statuses, attribution ambiguity, mobile feature gaps.
- Retrieval cues: `Campaign influence`, `Primary Campaign Source`, `Campaign Member Statuses`, `marketing user`.

### Turn Opportunities into Deals (p.114)
- Purpose: Move opportunities through staged sales cycles with accurate products, pricing, quotes, and close plans.
- Key objects/entities: Opportunity, Opportunity Stage, Opportunity Product, Quotes, Price Books, Competitors, Splits.
- Core workflows: Qualify and stage opportunities, attach products/pricing, manage quotes, forecast and close.
- Common setup surfaces: Sales process, stage definitions, page layouts, validation/automation, product and price book setup.
- Typical pitfalls/constraints: Stage drift, inconsistent close criteria, quote/product misconfiguration, poor forecast hygiene.
- Retrieval cues: `Opportunities`, `sales process`, `stage`, `quotes`, `price books`, `opportunity products`.

### Manage Accounts and Contacts (p.202)
- Purpose: Maintain accurate company/person relationships and shared context for revenue teams.
- Key objects/entities: Account, Contact, Person Account, Contact Roles, Related Contacts, Account Teams.
- Core workflows: Create and maintain account/contact records, manage relationships, collaborate across teams.
- Common setup surfaces: Account/contact field model, duplicate/matching rules, sharing model, page layouts.
- Typical pitfalls/constraints: Duplicate records, weak ownership definitions, unclear relationship semantics, access issues.
- Retrieval cues: `Accounts and Contacts`, `person accounts`, `related contacts`, `account teams`, `duplicate management`.

### Showing Customers and Prospects on a Map (p.299)
- Purpose: Improve territory coverage and route planning by visualizing records geographically.
- Key objects/entities: Salesforce Maps Lite, mapped customer/prospect records, route plans.
- Core workflows: Locate accounts/leads on map, plan rep routes, reduce travel gaps.
- Common setup surfaces: Maps Lite enablement and address/data quality prerequisites.
- Typical pitfalls/constraints: Incomplete or inaccurate geospatial address data.
- Retrieval cues: `Salesforce Maps Lite`, `map`, `routes`, `appointments`.

### Manage a Sales Team (p.302)
- Purpose: Operationalize team-level execution with forecasts, territories, and shared deal ownership.
- Key objects/entities: Forecasts, Enterprise Territory Management, Opportunity Splits, Sales Teams, Path, WDC.
- Core workflows: Forecast pipeline, assign territories, distribute credit/revenue, guide process adherence.
- Common setup surfaces: Forecast settings, territory model, split types, team roles, guidance components.
- Typical pitfalls/constraints: Territory overlap, split policy ambiguity, weak forecast categories/process discipline.
- Retrieval cues: `Forecast`, `Enterprise Territory Management`, `splits`, `Path`, `WDC`, `sales team`.

### Artificial Intelligence and Sales Cloud (p.572)
- Purpose: Apply Einstein capabilities to automate data capture and prioritize selling actions.
- Key objects/entities: Einstein suggestions/recommendations, predictive models, activity capture surfaces.
- Core workflows: Surface best actions, reduce manual entry, improve prioritization and conversion likelihood.
- Common setup surfaces: Einstein feature enablement, data prerequisites, user access and trust controls.
- Typical pitfalls/constraints: Model quality dependence on data health; expectation mismatch on automation scope.
- Retrieval cues: `Einstein`, `predictive analysis`, `automates data entry`, `AI in Sales Cloud`.

### Digital Engagement for Sales Cloud (p.588)
- Purpose: Extend rep communication through messaging/chat channels from Sales Console workflows.
- Key objects/entities: Lightning Sales Console channels, chat/messaging apps, Omni-Channel routing, workflow queue.
- Core workflows: Engage prospects in digital channels, route inbound conversations to correct teams.
- Common setup surfaces: Console channel configuration, routing rules, channel access permissions.
- Typical pitfalls/constraints: Channel sprawl, routing misconfiguration, uneven rep channel adoption.
- Retrieval cues: `Digital Engagement`, `Lightning Sales Console`, `Omni-Channel`, `messaging`, `chat`.

### More Sales Features (p.590)
- Purpose: Reference upgraded or legacy-adjacent feature documentation not central to current core flows.
- Key objects/entities: Feature-specific legacy or transitional components.
- Core workflows: Locate version-specific behavior when current flow docs are insufficient.
- Common setup surfaces: Feature-level help references.
- Typical pitfalls/constraints: Mixing legacy and current guidance without release checks.
- Retrieval cues: `More Sales Features`, `earlier versions`, `upgraded features`.

### Resources for the Sales Professional (p.596)
- Purpose: Provide enablement links and learning resources for admins, ops, and sellers.
- Key objects/entities: Help resources, guides, tip sheets, learning content.
- Core workflows: Upskill teams, validate practices, support rollout and adoption.
- Common setup surfaces: Learning path adoption, enablement plans.
- Typical pitfalls/constraints: Treating guidance as static; not updating for newer releases.
- Retrieval cues: `resources`, `tip sheets`, `learn`, `Salesforce Help`.

## Task-Oriented Retrieval Index
- If asked about pipeline stage design, close criteria, quotes, or products: start at [Turn Opportunities into Deals (p.114)](#turn-opportunities-into-deals-p114).
- If asked about campaign attribution, member statuses, hierarchy, or ROI reporting: start at [Capture ROI with Campaigns (p.7)](#capture-roi-with-campaigns-p7).
- If asked about account/contact structure, duplicates, or relationship governance: start at [Manage Accounts and Contacts (p.202)](#manage-accounts-and-contacts-p202).
- If asked about daily rep workspace and prioritization UX: start at [Seller Home (p.4)](#see-an-overview-of-metrics-goals-suggestions-tasks-and-activities-in-seller-home-p4).
- If asked about forecast operations, territories, team selling, or credit allocation: start at [Manage a Sales Team (p.302)](#manage-a-sales-team-p302).
- If asked about map-based planning or geographic routing: start at [Showing Customers and Prospects on a Map (p.299)](#showing-customers-and-prospects-on-a-map-p299).
- If asked about AI recommendations, predictive support, or automation assist: start at [Artificial Intelligence and Sales Cloud (p.572)](#artificial-intelligence-and-sales-cloud-p572).
- If asked about chat/messaging workflows in console environments: start at [Digital Engagement for Sales Cloud (p.588)](#digital-engagement-for-sales-cloud-p588).
- If asked about rollout strategy or implementation readiness: start at [Learn About, Implement, and Optimize Sales Cloud Features (p.2)](#learn-about-implement-and-optimize-sales-cloud-features-p2).

## Known Limits of This Extract
- OCR/extraction artifacts are present: broken pagination, occasional spelling noise, repeated headers, and formatting drift.
- Page-number references are from the extracted source index and may not map one-to-one to other rendered formats.
- Some section details can be truncated or duplicated across extracted pages.
- This context file is optimized for orientation and retrieval, not for legal/contractual interpretation of product behavior.
- For edge configuration decisions, confirm in the current official Salesforce documentation before deployment.
