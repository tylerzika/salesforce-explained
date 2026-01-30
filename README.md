# Salesforce Explained: Global Sales Cloud Packages

This repository showcases two unlocked packages designed to demonstrate **Salesforce Sales Cloud best practices** for international sales scenarios. These packages prioritize **declarative (configuration-based) development** over custom code, following the principle of "clicks, not code."

## 🎯 Design Philosophy

### Declarative Development First
These packages demonstrate **Sales Cloud best practices** by:
- **Using configuration over code**: Flows, Formula Fields, Assignment Rules
- **Leveraging platform features**: Native forecasting, lead management, reporting
- **Minimizing custom development**: LWC only when platform limits are reached
- **Enabling admin maintenance**: Point-and-click configuration

### When Custom Code is Appropriate
Custom code (Apex/LWC) is used **only** to demonstrate:
- Platform limitations that can't be solved declaratively
- Advanced UI requirements beyond standard dashboard capabilities
- Specific visualizations not available in standard components

## 📦 Packages Overview

### 1. GlobalSalesCore
**Backend/Core Functionality Package (100% Declarative)**

The GlobalSalesCore package provides the foundational data model and business logic for managing international sales operations **using only declarative features**.

**Key Features:**
- **Custom Objects**: RegionalQuota__c, MultiCurrencySettings__c
- **Custom Fields**: Extended Lead, Opportunity, and Account objects with region and currency fields
- **Formula Fields**: Calculated Priority for automatic opportunity prioritization
- **Record-Triggered Flows**: 
  - Lead follow-up automation (creates tasks for high-priority leads)
  - Forecasting adjustment (auto-categorizes opportunities based on probability)
  - Region sync from Lead to Opportunity
- **Assignment Rules**: Automated lead routing to regional teams
- **Permission Sets**: Role-based access for regional sales reps and managers

**No Apex Code**: Demonstrates that complex business logic can be implemented declaratively.

[📖 View GlobalSalesCore Documentation](packages/GlobalSalesCore/README.md)

### 2. SalesInsightsUI
**Frontend/UI Package (LWC Only for Platform Limitations)**

The SalesInsightsUI package provides visualizations for monitoring global sales performance. Uses **standard reports** where possible, and **custom LWC only** for visualizations that exceed platform capabilities.

**Key Features:**
- **Standard Reports** (Preferred):
  - Regional Opportunity Pipeline (standard summary report)
  - Regional Revenue Performance (standard report with chart)
- **Lightning Web Components** (Only for platform limitations):
  - Regional Dashboard: Interactive filtering not available in standard dashboards
  - Opportunity Heatmap: Matrix visualization not supported by standard charts
- **Lightning App Page**: Combines components for executive view
- **Responsive Design**: Mobile and desktop optimized

**Why LWC**: Used only to demonstrate UI customization beyond standard dashboard capabilities (heatmaps, real-time filtering, multi-metric cards).

[📖 View SalesInsightsUI Documentation](packages/SalesInsightsUI/README.md)

## 🎯 Use Cases

These packages demonstrate declarative solutions for:
- **Multi-Regional Sales Management**: Handle sales operations across North America, EMEA, APAC, and LATAM
- **Automated Lead Routing**: Assignment rules route leads without custom code
- **Intelligent Forecasting**: Flows automatically categorize opportunities
- **Priority Calculation**: Formula fields determine priority in real-time
- **Sales Analytics**: Standard reports with custom visualizations only when needed
- **Quota Management**: Track regional quotas by fiscal period

## 🏗️ Architecture

The packages follow a **declarative-first architecture** pattern:

```
┌─────────────────────────────────────────────┐
│     SalesInsightsUI (UI Layer)             │
│  - Standard Reports (PRIMARY)               │
│  - LWC Components (only for limitations)    │
│  - Lightning Pages                          │
└──────────────┬──────────────────────────────┘
               │ depends on
               ↓
┌─────────────────────────────────────────────┐
│  GlobalSalesCore (Business Logic - 100%     │
│                   Declarative)              │
│  - Data Model (Objects & Fields)            │
│  - Formula Fields                           │
│  - Record-Triggered Flows                   │
│  - Assignment Rules                         │
│  - Permission Sets                          │
└─────────────────────────────────────────────┘
```

**Benefits of This Architecture:**
- **Admin-Maintainable**: No Apex means admins can modify flows and rules
- **Lower TCO**: Less custom code to maintain and test
- **Faster Delivery**: Declarative features deploy more quickly
- **Platform Upgrades**: Salesforce maintains declarative features
- **Governor Limit Friendly**: Platform-optimized automation

## 🚀 Quick Start

### Prerequisites
- Salesforce org with Sales Cloud
- Salesforce CLI installed
- API version 65.0 or higher
- System Administrator access

### Installation

#### Option 1: Deploy All Packages
```bash
# Authenticate to your org
sf org login web --alias myorg

# Deploy GlobalSalesCore first (100% declarative)
sf project deploy start --source-dir packages/GlobalSalesCore --target-org myorg

# Then deploy SalesInsightsUI
sf project deploy start --source-dir packages/SalesInsightsUI --target-org myorg
```

#### Option 2: Create and Install as Unlocked Packages
```bash
# Create GlobalSalesCore package
sf package create --name "GlobalSalesCore" \
  --description "Declarative core functionality for global sales" \
  --package-type Unlocked \
  --path packages/GlobalSalesCore

# Create package version
sf package version create --package GlobalSalesCore \
  --installation-key-bypass --wait 10

# Install to your org
sf package install --package 04t... --target-org myorg --wait 10

# Repeat for SalesInsightsUI
sf package create --name "SalesInsightsUI" \
  --description "UI components for global sales insights" \
  --package-type Unlocked \
  --path packages/SalesInsightsUI

sf package version create --package SalesInsightsUI \
  --installation-key-bypass --wait 10

sf package install --package 04t... --target-org myorg --wait 10
```

### Post-Installation Configuration

1. **Assign Permission Sets**
   ```bash
   sf org assign permset --name Regional_Sales_Rep --target-org myorg
   sf org assign permset --name Regional_Sales_Manager --target-org myorg
   ```

2. **Activate Flows**
   - Navigate to Setup > Flows
   - Verify flows are Active: Lead Follow-Up, Forecasting Adjustment, Region Sync

3. **Configure Assignment Rules**
   - Navigate to Setup > Lead Assignment Rules
   - Update "Regional Lead Assignment" with actual user/queue assignments
   - Activate the rule

4. **Add Components to Pages** (Optional - for LWC components)
   - Open Lightning App Builder
   - Add Regional Dashboard and Opportunity Heatmap to desired pages
   - Activate the "Global Sales Insights" app page

5. **Set Up Sample Data** (Optional)
   - Create Regional Quota records
   - Create Multi-Currency Settings
   - Update existing Opportunities with SalesRegion__c values

## 📊 Package Contents

### GlobalSalesCore Contents (100% Declarative)
```
packages/GlobalSalesCore/
├── main/default/
│   ├── objects/
│   │   ├── RegionalQuota__c/          # Custom object & 5 fields
│   │   ├── MultiCurrencySettings__c/  # Custom object & 4 fields
│   │   ├── Lead/fields/               # 2 custom fields
│   │   ├── Opportunity/fields/        # 3 custom fields (including 1 formula)
│   │   └── Account/fields/            # 2 custom fields
│   ├── flows/                         # 3 record-triggered flows
│   │   ├── Lead_Follow_Up_Automation.flow-meta.xml
│   │   ├── Forecasting_Adjustment_Automation.flow-meta.xml
│   │   └── Lead_to_Opportunity_Region_Sync.flow-meta.xml
│   ├── assignmentRules/               # Lead assignment rules
│   │   └── Lead.assignmentRules-meta.xml
│   └── permissionsets/                # 2 permission sets
│       ├── Regional_Sales_Rep.permissionset-meta.xml
│       └── Regional_Sales_Manager.permissionset-meta.xml
└── README.md
```

### SalesInsightsUI Contents (Reports + LWC for Limitations)
```
packages/SalesInsightsUI/
├── main/default/
│   ├── reports/GlobalSalesReports/    # 2 standard reports (preferred)
│   │   ├── Regional_Opportunity_Pipeline.report-meta.xml
│   │   └── Regional_Revenue_Performance.report-meta.xml
│   ├── lwc/                           # 2 LWC (only for limitations)
│   │   ├── regionalDashboard/
│   │   └── opportunityHeatmap/
│   └── flexipages/                    # 1 Lightning page
│       └── Global_Sales_Insights.flexipage-meta.xml
└── README.md
```

## 🧪 Testing

### Testing Declarative Features
```bash
# No Apex tests required - all automation is declarative!

# Test flows manually:
# 1. Create a Lead with High priority -> Task should be created
# 2. Update Opportunity probability to 85% -> Forecast Category = "Best Case"
# 3. Convert Lead with region -> Opportunity inherits region

# Test assignment rules:
# Create Lead with Preferred Region and High Priority -> Should auto-assign
```

### Testing Components
- LWC components use mock data for demonstration
- In production, connect components to standard reports or Apex if needed
- Use Salesforce Inspector or Developer Console to debug

## 📚 Learning Resources

### Salesforce Documentation
- [Flow Builder](https://help.salesforce.com/s/articleView?id=sf.flow.htm)
- [Formula Fields](https://help.salesforce.com/s/articleView?id=sf.customize_functions.htm)
- [Assignment Rules](https://help.salesforce.com/s/articleView?id=sf.customize_leadrules.htm)
- [Standard Reports and Dashboards](https://help.salesforce.com/s/articleView?id=sf.reports_dashboards.htm)
- [Lightning Web Components](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)

### Trailhead Modules
- [Build Flows with Flow Builder](https://trailhead.salesforce.com/content/learn/modules/business_process_automation)
- [Formulas and Validations](https://trailhead.salesforce.com/content/learn/modules/point_click_business_logic)
- [Reports and Dashboards](https://trailhead.salesforce.com/content/learn/modules/reports_dashboards)
- [Lightning Web Components Basics](https://trailhead.salesforce.com/content/learn/modules/lightning-web-components-basics)

## 🤝 Contributing

This is an educational repository. Feel free to fork and extend for your own learning!

**Suggestions for Extension (Declarative First):**
- Add more regions and currencies
- Create additional flows for territory management
- Build more standard reports and dashboards
- Add validation rules for data quality
- Implement approval processes for discounts
- Create additional assignment rules

## 📝 Version History

### v1.0.0 (Current)
- **GlobalSalesCore**: 100% declarative with flows, formula fields, and assignment rules
- **SalesInsightsUI**: Standard reports plus LWC only for platform limitations
- Removed Apex classes in favor of declarative automation
- Added formula field for calculated priority
- Enhanced flows with full business logic
- Added assignment rules for lead routing

## 📄 Best Practices Summary

### ✅ DO (Demonstrated in this repo)
- Use Flows for process automation
- Use Formula Fields for calculations
- Use Assignment Rules for routing
- Use Standard Reports first
- Use LWC only for platform limitations
- Document why custom code is necessary

### ❌ DON'T (Avoided in this repo)
- Write Apex for logic that Flows can handle
- Create custom pages for standard reporting
- Use code for routing (Assignment Rules exist)
- Write code for simple calculations (use formulas)
- Add custom code without justification

## 📄 License

This project is provided as an educational resource for the Salesforce community.

## 🙋 Support

For questions or issues:
1. Review package README files for detailed documentation
2. Check Salesforce documentation links above
3. Create an issue in this repository

---

**Built with ❤️ for the Salesforce Community - Clicks, Not Code!**
