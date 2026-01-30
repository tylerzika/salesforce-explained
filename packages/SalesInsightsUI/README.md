# SalesInsightsUI Package

## Overview
The **SalesInsightsUI** package demonstrates how a Flow can call Apex code from a dependent package (GlobalSalesCore). This showcases package dependency and integration between Flow and Apex.

## Contents

### Record-Triggered Flow
**Set Opportunity Priority**
- Triggers when Opportunity is created or updated
- Calls `OpportunityPriorityCalculator` from GlobalSalesCore package
- Updates the `CalculatedPriority__c` field with the result
- Demonstrates cross-package Flow-to-Apex integration

### Custom Field
**Opportunity.CalculatedPriority__c**
- Text field to store the priority calculated by Apex
- Updated automatically by the Flow

## Dependencies

**Requires GlobalSalesCore package** to be installed first.

The Flow in this package calls the `OpportunityPriorityCalculator` Apex class from GlobalSalesCore, demonstrating how packages can depend on and integrate with each other.

## Installation

```bash
# First install GlobalSalesCore
sf project deploy start --source-dir packages/GlobalSalesCore --target-org myorg

# Then install SalesInsightsUI
sf project deploy start --source-dir packages/SalesInsightsUI --target-org myorg
```

## How It Works

1. **Opportunity Created/Updated** → Flow triggers
2. **Flow calls Apex Action** → Invokes `OpportunityPriorityCalculator.calculatePriority()`
3. **Apex calculates priority** → Based on Amount and SalesRegion
4. **Flow updates field** → Sets `CalculatedPriority__c` with result

## Purpose

This package demonstrates:
- **Package dependencies**: How one package can depend on another
- **Flow-to-Apex integration**: Calling Apex from Flow using Actions
- **Cross-package calls**: Flow in one package calling Apex in another
- **Simple automation**: Keeping complexity minimal and focused

## Testing

Create or update an Opportunity:
- Set Amount > $100,000 → Priority = "High"
- Set SalesRegion = "EMEA" or "APAC" → Priority = "Medium"  
- Otherwise → Priority = "Low"

The `CalculatedPriority__c` field will be updated automatically.

## Version

- **v1.0.0**: Initial release with Flow calling Apex from dependent package
