# GlobalSalesCore Package

## Overview
The **GlobalSalesCore** package provides a simple Apex utility for calculating opportunity priority. This package demonstrates how to create reusable Apex code that can be called from Flows in dependent packages.

## Contents

### Apex Class
**OpportunityPriorityCalculator**
- @InvocableMethod that calculates opportunity priority
- Can be called from Flow using an Action
- Priority logic:
  - **High**: Amount > $100,000
  - **Medium**: Region is EMEA or APAC
  - **Low**: Everything else

### Custom Field
**Opportunity.SalesRegion__c**
- Picklist field with values: North America, EMEA, APAC, LATAM
- Used by the priority calculator

## Installation

```bash
# Deploy the package
sf project deploy start --source-dir packages/GlobalSalesCore --target-org myorg
```

## Usage

This Apex class is designed to be called from Flow:
1. Add an "Action" element in Flow Builder
2. Search for "Calculate Opportunity Priority"
3. Pass the Opportunity ID
4. Receive the calculated priority

## Purpose

This package demonstrates:
- Creating an @InvocableMethod for Flow integration
- Building reusable Apex utilities
- Package dependency (SalesInsightsUI depends on this)

## Test Coverage

Includes `OpportunityPriorityCalculatorTest` with 100% code coverage testing:
- High priority calculation
- Medium priority calculation
- Low priority calculation  
- Bulk processing

## Version

- **v1.0.0**: Initial release with priority calculator
