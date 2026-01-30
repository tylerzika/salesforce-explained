# Salesforce Explained: Package Dependency Example

This repository demonstrates **package dependencies** in Salesforce through a simple, focused example showing how a Flow in one package can call Apex code from another package.

## 📦 Packages

### 1. GlobalSalesCore (Apex Package)
**Contains reusable Apex code**

- **Apex Class**: `OpportunityPriorityCalculator`
  - @InvocableMethod that can be called from Flow
  - Calculates priority based on opportunity amount and region
  - Returns: High, Medium, or Low priority
- **Custom Field**: `Opportunity.SalesRegion__c` (picklist)
- **Test Coverage**: 100% with `OpportunityPriorityCalculatorTest`

[📖 View GlobalSalesCore Documentation](packages/GlobalSalesCore/README.md)

### 2. SalesInsightsUI (Flow Package)
**Depends on GlobalSalesCore - calls its Apex from Flow**

- **Record-Triggered Flow**: `Set Opportunity Priority`
  - Triggers on Opportunity create/update
  - Calls `OpportunityPriorityCalculator` from GlobalSalesCore
  - Updates `CalculatedPriority__c` field with result
- **Custom Field**: `Opportunity.CalculatedPriority__c` (text)
- **Dependency**: Requires GlobalSalesCore package

[📖 View SalesInsightsUI Documentation](packages/SalesInsightsUI/README.md)

## 🎯 What This Demonstrates

### Package Dependency
- **SalesInsightsUI depends on GlobalSalesCore**
- Flow in one package calling Apex from another package
- Clean separation: Apex logic in one package, Flow automation in another

### Flow-to-Apex Integration
- Using @InvocableMethod to make Apex callable from Flow
- Passing data between Flow and Apex
- Updating records with Apex calculation results

### Simplicity
- **Just 2 Apex classes** (1 main + 1 test)
- **Just 1 Flow** (calls the Apex)
- **Just 2 custom fields** (region input, priority output)
- Focused on demonstrating the core concept

## 🏗️ Architecture

```
┌─────────────────────────────────┐
│   SalesInsightsUI (Flow)        │
│                                 │
│   Flow: Set Opportunity         │
│   Priority                      │
│   ↓                             │
│   Calls Apex Action             │
└────────────┬────────────────────┘
             │ depends on
             ↓
┌─────────────────────────────────┐
│   GlobalSalesCore (Apex)        │
│                                 │
│   OpportunityPriorityCalculator │
│   @InvocableMethod             │
│   ↓                             │
│   Returns Priority              │
└─────────────────────────────────┘
```

## 🚀 Quick Start

### Installation

```bash
# Authenticate to your org
sf org login web --alias myorg

# Deploy GlobalSalesCore first (Apex package)
sf project deploy start --source-dir packages/GlobalSalesCore --target-org myorg

# Deploy SalesInsightsUI second (Flow package that calls the Apex)
sf project deploy start --source-dir packages/SalesInsightsUI --target-org myorg
```

### Testing

1. Create or update an Opportunity
2. Set `Amount` > $100,000 → `CalculatedPriority__c` = "High"
3. Set `SalesRegion__c` = "EMEA" → `CalculatedPriority__c` = "Medium"
4. Otherwise → `CalculatedPriority__c` = "Low"

The Flow automatically calls the Apex and updates the priority field.

## 📊 Package Contents

### GlobalSalesCore (Apex Package)
```
packages/GlobalSalesCore/
├── main/default/
│   ├── classes/
│   │   ├── OpportunityPriorityCalculator.cls
│   │   ├── OpportunityPriorityCalculator.cls-meta.xml
│   │   ├── OpportunityPriorityCalculatorTest.cls
│   │   └── OpportunityPriorityCalculatorTest.cls-meta.xml
│   └── objects/Opportunity/fields/
│       └── SalesRegion__c.field-meta.xml
└── README.md
```

### SalesInsightsUI (Flow Package)
```
packages/SalesInsightsUI/
├── main/default/
│   ├── flows/
│   │   └── Set_Opportunity_Priority.flow-meta.xml
│   └── objects/Opportunity/fields/
│       └── CalculatedPriority__c.field-meta.xml
└── README.md
```

## 📝 Key Concepts

### Why This Example?

**Simple & Focused**
- Demonstrates one clear concept: Flow calling Apex across packages
- Easy to understand and modify
- No unnecessary complexity

**Real-World Pattern**
- Common scenario: Reusable Apex utilities called by Flows
- Shows proper package separation
- Demonstrates dependency management

**Best Practices**
- @InvocableMethod for Flow integration
- Test coverage included
- Clear documentation

## 🧪 Running Tests

```bash
# Run Apex tests
sf apex run test --tests OpportunityPriorityCalculatorTest --result-format human --target-org myorg
```

Expected results:
- 4 test methods pass
- 100% code coverage

## 📚 Learning Resources

- [Salesforce Unlocked Packages](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_unlocked_pkg_intro.htm)
- [Invocable Methods](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm)
- [Flow Actions](https://help.salesforce.com/s/articleView?id=sf.flow_ref_elements_apex.htm)

## 📄 License

This project is provided as an educational resource for the Salesforce community.

---

**Simple. Focused. Educational.**
