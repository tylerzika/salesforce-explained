# Salesforce Explained: Global Sales Cloud Packages

This repository showcases two unlocked packages designed to demonstrate Salesforce Sales Cloud capabilities for international sales scenarios. These packages provide a modular, educational resource for understanding how to build and deploy scalable sales solutions.

## 📦 Packages Overview

### 1. GlobalSalesCore
**Backend/Core Functionality Package**

The GlobalSalesCore package provides the foundational data model and business logic for managing international sales operations.

**Key Features:**
- **Custom Objects**: RegionalQuota__c, MultiCurrencySettings__c
- **Custom Fields**: Extended Lead, Opportunity, and Account objects with region and currency fields
- **Apex Classes**: LeadConversionHandler, OpportunityRoutingService with comprehensive test coverage
- **Flows**: Automated lead follow-up and forecasting adjustments
- **Permission Sets**: Role-based access for regional sales reps and managers
- **Sharing Rules**: Region-specific data access controls

[📖 View GlobalSalesCore Documentation](packages/GlobalSalesCore/README.md)

### 2. SalesInsightsUI
**Frontend/UI Package**

The SalesInsightsUI package provides interactive visualizations and reporting capabilities for monitoring global sales performance.

**Key Features:**
- **Lightning Web Components**:
  - Regional Dashboard: Interactive metrics by region
  - Opportunity Heatmap: Visual pipeline analysis
- **Pre-configured Reports**: Regional pipeline and revenue performance reports
- **Lightning App Page**: "Global Sales Insights" page combining all UI components
- **Responsive Design**: Mobile and desktop optimized

[📖 View SalesInsightsUI Documentation](packages/SalesInsightsUI/README.md)

## 🎯 Use Cases

These packages demonstrate solutions for:
- **Multi-Regional Sales Management**: Handle sales operations across North America, EMEA, APAC, and LATAM
- **Multi-Currency Support**: Track and convert currency for international deals
- **Lead Routing**: Automatically route leads to appropriate regional teams
- **Forecasting**: Categorize and track opportunities for accurate forecasting
- **Sales Analytics**: Visual dashboards and reports for executive insights
- **Quota Management**: Set and track regional quotas by fiscal period

## 🏗️ Architecture

The packages follow a **modular architecture** pattern:

```
┌─────────────────────────────────────┐
│      SalesInsightsUI (UI Layer)    │
│   - LWC Components                  │
│   - Reports & Dashboards            │
│   - Lightning Pages                 │
└─────────────┬───────────────────────┘
              │ depends on
              ↓
┌─────────────────────────────────────┐
│   GlobalSalesCore (Business Logic)  │
│   - Data Model                      │
│   - Apex Classes                    │
│   - Flows & Automation              │
│   - Security & Permissions          │
└─────────────────────────────────────┘
```

**Benefits of This Architecture:**
- **Separation of Concerns**: Backend logic independent from UI
- **Reusability**: Core package can be used with different UI implementations
- **Maintainability**: Updates to UI don't affect core business logic
- **Scalability**: Easy to extend with additional packages

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

# Deploy GlobalSalesCore first
sf project deploy start --source-dir packages/GlobalSalesCore --target-org myorg

# Then deploy SalesInsightsUI
sf project deploy start --source-dir packages/SalesInsightsUI --target-org myorg
```

#### Option 2: Create and Install as Unlocked Packages
```bash
# Create GlobalSalesCore package
sf package create --name "GlobalSalesCore" \
  --description "Core functionality for global sales operations" \
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

2. **Add Components to Pages**
   - Open Lightning App Builder
   - Add Regional Dashboard and Opportunity Heatmap to desired pages
   - Activate the "Global Sales Insights" app page

3. **Set Up Sample Data** (Optional)
   - Create Regional Quota records
   - Create Multi-Currency Settings
   - Update existing Opportunities with SalesRegion__c values

## 📊 Package Contents

### GlobalSalesCore Contents
```
packages/GlobalSalesCore/
├── main/default/
│   ├── objects/
│   │   ├── RegionalQuota__c/          # Custom object & fields
│   │   ├── MultiCurrencySettings__c/  # Custom object & fields
│   │   ├── Lead/fields/               # Custom fields
│   │   ├── Opportunity/fields/        # Custom fields
│   │   └── Account/fields/            # Custom fields
│   ├── classes/
│   │   ├── LeadConversionHandler.cls
│   │   ├── LeadConversionHandlerTest.cls
│   │   ├── OpportunityRoutingService.cls
│   │   └── OpportunityRoutingServiceTest.cls
│   ├── flows/
│   │   ├── Lead_Follow_Up_Automation.flow-meta.xml
│   │   └── Forecasting_Adjustment_Automation.flow-meta.xml
│   └── permissionsets/
│       ├── Regional_Sales_Rep.permissionset-meta.xml
│       └── Regional_Sales_Manager.permissionset-meta.xml
└── README.md
```

### SalesInsightsUI Contents
```
packages/SalesInsightsUI/
├── main/default/
│   ├── lwc/
│   │   ├── regionalDashboard/
│   │   │   ├── regionalDashboard.js
│   │   │   ├── regionalDashboard.html
│   │   │   ├── regionalDashboard.css
│   │   │   └── regionalDashboard.js-meta.xml
│   │   └── opportunityHeatmap/
│   │       ├── opportunityHeatmap.js
│   │       ├── opportunityHeatmap.html
│   │       ├── opportunityHeatmap.css
│   │       └── opportunityHeatmap.js-meta.xml
│   ├── reports/GlobalSalesReports/
│   │   ├── Regional_Opportunity_Pipeline.report-meta.xml
│   │   └── Regional_Revenue_Performance.report-meta.xml
│   └── flexipages/
│       └── Global_Sales_Insights.flexipage-meta.xml
└── README.md
```

## 🧪 Testing

### Run Apex Tests
```bash
# Run all tests in GlobalSalesCore
sf apex run test --tests LeadConversionHandlerTest,OpportunityRoutingServiceTest \
  --result-format human --target-org myorg

# Check code coverage
sf apex get test --test-run-id 707... --code-coverage --target-org myorg
```

### Component Testing
- LWC components use mock data for demonstration
- In production, connect components to Apex controllers for real data
- Use Salesforce Inspector or Developer Console to debug

## 📚 Learning Resources

### Salesforce Documentation
- [Unlocked Packages](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_unlocked_pkg_intro.htm)
- [Lightning Web Components](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [Flow Builder](https://help.salesforce.com/s/articleView?id=sf.flow.htm)

### Trailhead Modules
- [Build Unlocked Packages](https://trailhead.salesforce.com/content/learn/modules/unlocked-packages-for-customers)
- [Lightning Web Components Basics](https://trailhead.salesforce.com/content/learn/modules/lightning-web-components-basics)
- [Apex Testing](https://trailhead.salesforce.com/content/learn/modules/apex_testing)

## 🤝 Contributing

This is an educational repository. Feel free to fork and extend for your own learning!

**Suggestions for Extension:**
- Add more regions and currencies
- Implement actual API callouts for currency conversion
- Add AI-powered opportunity scoring
- Create mobile-optimized views
- Add Einstein Analytics dashboards
- Implement automated territory assignment

## 📝 Version History

### v1.0.0 (Current)
- Initial release of GlobalSalesCore package
- Initial release of SalesInsightsUI package
- Core objects, fields, and relationships
- Apex classes with test coverage
- LWC components with mock data
- Pre-configured reports and dashboards
- Permission sets and security model

## 📄 License

This project is provided as an educational resource for the Salesforce community.

## 🙋 Support

For questions or issues:
1. Review package README files for detailed documentation
2. Check Salesforce documentation links above
3. Create an issue in this repository

---

**Built with ❤️ for the Salesforce Community**
