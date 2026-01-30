# GlobalSalesCore Package

## Overview
The **GlobalSalesCore** package provides core backend functionality for international sales operations in Salesforce Sales Cloud. This package is designed to help organizations manage multi-regional sales processes, currency handling, lead routing, and forecasting at a global scale.

## Features

### Custom Objects
1. **Regional Quota (RegionalQuota__c)**
   - Manages sales quotas for different regions and territories
   - Fields:
     - Region (Picklist): North America, EMEA, APAC, LATAM
     - Quota Amount (Currency): Target quota for the region
     - Fiscal Year (Text): Target fiscal year
     - Fiscal Quarter (Picklist): Q1, Q2, Q3, Q4
     - Actual Revenue (Currency): Actual revenue achieved

2. **Multi-Currency Settings (MultiCurrencySettings__c)**
   - Configuration settings for multi-currency support
   - Fields:
     - Currency Code (Text): ISO currency code (e.g., USD, EUR, GBP)
     - Conversion Rate (Number): Exchange rate for conversions
     - Region Association (Picklist): Associated sales region
     - Is Active (Checkbox): Whether the currency is active

### Custom Fields on Standard Objects

#### Lead
- **Preferred Region**: Sales region for lead routing
- **Routing Priority**: Priority level for lead assignment (High, Medium, Low)

#### Opportunity
- **Sales Region**: Region where the opportunity is being managed
- **Forecast Category**: Categorization for forecasting (Pipeline, Best Case, Commit, Omitted)

#### Account
- **Preferred Currency**: Default currency for the account
- **Global Account Tier**: Account tier (Enterprise, Strategic, Standard)

### Apex Classes

#### LeadConversionHandler
Handles lead conversion with region-specific business logic:
- `convertLeadsWithRegion()`: Converts leads and automatically assigns region to opportunities
- `routeLeadsToRegionalQueue()`: Routes leads to appropriate regional queues

#### OpportunityRoutingService
Manages opportunity routing and forecasting:
- `routeOpportunitiesByRegion()`: Routes opportunities based on region and account tier
- `assignToRegionalReps()`: Assigns opportunities to regional sales representatives
- `updateForecastCategories()`: Automatically updates forecast categories based on stage and probability

### Flows

#### Lead Follow-Up Automation
- Trigger: After Lead is created or updated
- Purpose: Automates follow-up tasks for high-priority leads
- Status: Active

#### Forecasting Adjustment Automation
- Trigger: After Opportunity is created or updated
- Purpose: Automatically adjusts forecast categories when stage or probability changes
- Status: Active

### Permission Sets

#### Regional Sales Rep
Permissions for regional sales representatives:
- Read access to Regional Quotas and Multi-Currency Settings
- Edit access to Lead and Opportunity regional fields
- Read access to Account currency and tier information

#### Regional Sales Manager
Enhanced permissions for regional sales managers:
- Full CRUD on Regional Quotas
- Create and edit Multi-Currency Settings
- Full access to all custom fields
- Execute Apex classes for lead conversion and opportunity routing

## Installation

### Prerequisites
- Salesforce org with Sales Cloud enabled
- API version 65.0 or higher
- System Administrator access

### Deployment Steps

1. **Using Salesforce CLI**
   ```bash
   # Authenticate to your org
   sf org login web --alias myorg

   # Create the package
   sf package create --name "GlobalSalesCore" --description "Core functionality for global sales operations" --package-type Unlocked --path packages/GlobalSalesCore

   # Create a package version
   sf package version create --package GlobalSalesCore --installation-key-bypass --wait 10

   # Install the package version
   sf package install --package 04t... --target-org myorg --wait 10
   ```

2. **Manual Deployment**
   ```bash
   sf project deploy start --source-dir packages/GlobalSalesCore --target-org myorg
   ```

## Configuration

### Post-Installation Steps

1. **Assign Permission Sets**
   - Assign "Regional Sales Rep" to regional sales users
   - Assign "Regional Sales Manager" to regional sales managers

2. **Configure Regional Quotas**
   - Navigate to Regional Quotas tab
   - Create quota records for each region and fiscal period
   - Set quota amounts based on sales targets

3. **Set Up Multi-Currency Settings**
   - Create currency configuration records
   - Define conversion rates for each region
   - Activate the currencies needed for your organization

4. **Customize Lead and Opportunity Page Layouts**
   - Add custom fields to appropriate page layouts
   - Set field-level security as needed

5. **Configure Flows**
   - Review and customize flow logic based on your business processes
   - Activate or deactivate flows as needed

## Usage Examples

### Converting Leads with Regional Assignment
```apex
// Convert multiple leads and assign regions
List<Id> leadIds = new List<Id>{'00Q...'};
List<Id> opportunityIds = LeadConversionHandler.convertLeadsWithRegion(leadIds);
```

### Routing Opportunities by Region
```apex
// Route opportunities to appropriate regional teams
List<Id> oppIds = new List<Id>{'006...'};
OpportunityRoutingService.routeOpportunitiesByRegion(oppIds);
```

### Updating Forecast Categories
```apex
// Update forecast categories based on current probability
List<Id> oppIds = new List<Id>{'006...'};
OpportunityRoutingService.updateForecastCategories(oppIds);
```

## Architecture

The package follows Salesforce best practices:
- **Bulkified Apex**: All Apex code handles bulk operations
- **Proper error handling**: Try-catch blocks for robust execution
- **Test coverage**: All Apex classes have corresponding test classes
- **Governor limits**: Efficient SOQL queries and DML operations
- **Security**: With sharing enforcement for data security

## Dependencies
This package has no external dependencies and can be installed independently.

## Support
For issues or questions about this package, please refer to the main repository documentation or create an issue in the repository.

## Version History
- **v1.0.0**: Initial release with core objects, Apex classes, flows, and permission sets

## License
This package is provided as an educational resource for the Salesforce community.
