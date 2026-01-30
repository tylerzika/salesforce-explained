# GlobalSalesCore Package

## Overview
The **GlobalSalesCore** package provides core backend functionality for international sales operations in Salesforce Sales Cloud. This package demonstrates **Sales Cloud best practices using declarative (configuration-based) features** to minimize custom code and leverage out-of-the-box platform capabilities.

## Design Philosophy
This package follows Salesforce best practices by prioritizing:
- **Declarative Development First**: Using Flows, Formula Fields, Assignment Rules, and Validation Rules
- **Configuration Over Code**: Leveraging platform features instead of custom Apex
- **Point-and-Click Administration**: Enabling admins to maintain and extend functionality
- **Standard Sales Cloud Features**: Utilizing native forecasting, lead management, and opportunity tracking

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
- **Preferred Region**: Sales region for lead routing (used by Assignment Rules)
- **Routing Priority**: Priority level for lead assignment (High, Medium, Low)

#### Opportunity
- **Sales Region**: Region where the opportunity is being managed
- **Forecast Category**: Categorization for forecasting (Pipeline, Best Case, Commit, Omitted)
- **Calculated Priority** (Formula): Automatically determines priority based on account tier, region, and amount

#### Account
- **Preferred Currency**: Default currency for the account
- **Global Account Tier**: Account tier (Enterprise, Strategic, Standard)

### Declarative Automation

#### Record-Triggered Flows

##### Lead Follow-Up Automation
- **Trigger**: After Lead is created or updated
- **Purpose**: Creates high-priority follow-up tasks for leads with high routing priority
- **Logic**: 
  - Checks if Lead has High routing priority
  - Creates Task assigned to Lead with priority and due date
- **Benefit**: Ensures immediate action on hot leads without custom code

##### Forecasting Adjustment Automation
- **Trigger**: Before Opportunity is saved (create or update)
- **Purpose**: Automatically categorizes opportunities for forecasting based on probability
- **Logic**:
  - Probability ≥ 90%: Forecast Category = "Commit"
  - Probability 70-89%: Forecast Category = "Best Case"
  - Probability 1-69%: Forecast Category = "Pipeline"
  - Probability = 0 or null: Forecast Category = "Omitted"
- **Benefit**: Consistent forecasting without manual updates or Apex code

##### Lead to Opportunity Region Sync
- **Trigger**: After Opportunity is created
- **Purpose**: Copies region from converted Lead to newly created Opportunity
- **Logic**:
  - Looks up the Lead that was converted to this Opportunity
  - Copies PreferredRegion__c from Lead to SalesRegion__c on Opportunity
- **Benefit**: Maintains regional context through lead conversion process

#### Assignment Rules

##### Regional Lead Assignment
- **Purpose**: Routes leads to appropriate regional sales teams
- **Criteria**: Based on Preferred Region and Routing Priority
- **Rules**:
  - High priority leads from each region route to regional specialists
  - Ensures leads reach the right team immediately upon creation
- **Benefit**: Automated lead distribution without Apex triggers

#### Formula Fields

##### Opportunity.CalculatedPriority__c
- **Type**: Text Formula
- **Logic**:
  - Returns "High" if: Account Tier is Enterprise/Strategic OR Amount > $100,000
  - Returns "Medium" if: Sales Region is EMEA or APAC
  - Returns "Low" otherwise
- **Benefit**: Real-time priority calculation without database updates or code

### Permission Sets

#### Regional Sales Rep
Permissions for regional sales representatives:
- Read access to Regional Quotas and Multi-Currency Settings
- Edit access to Lead and Opportunity regional fields
- Read-only access to formula fields and account information

#### Regional Sales Manager
Enhanced permissions for regional sales managers:
- Full CRUD on Regional Quotas
- Create and edit Multi-Currency Settings
- Full access to all custom fields
- Ability to modify assignment rules and flows

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

4. **Activate Assignment Rules**
   - Navigate to Setup > Lead Assignment Rules
   - Review the "Regional Lead Assignment" rule
   - Update with actual user/queue assignments for your org
   - Activate the rule

5. **Review and Test Flows**
   - Navigate to Setup > Flows
   - Review the three flows: Lead Follow-Up, Forecasting Adjustment, Region Sync
   - Flows are Active by default
   - Test with sample records to ensure proper behavior

6. **Customize Page Layouts**
   - Add custom fields to appropriate page layouts
   - Position Calculated Priority field prominently
   - Set field-level security as needed

## Usage Examples

### Lead Routing (Automated via Assignment Rules)
1. Create a new Lead with Preferred Region = "EMEA" and Routing Priority = "High"
2. Assignment rule automatically assigns to EMEA sales queue/rep
3. Lead Follow-Up Flow creates a high-priority task
4. Sales rep receives task notification

### Opportunity Forecasting (Automated via Flow)
1. Create or update Opportunity with Probability = 85%
2. Forecasting Adjustment Flow automatically sets Forecast Category = "Best Case"
3. No manual intervention required
4. Category updates immediately as probability changes

### Lead Conversion with Region Sync (Automated via Flow)
1. Convert a Lead that has Preferred Region = "North America"
2. Standard lead conversion creates Account, Contact, Opportunity
3. Region Sync Flow copies region to new Opportunity
4. Opportunity.SalesRegion__c = "North America" automatically

### Priority Calculation (Automatic via Formula)
- Formula field automatically evaluates when viewing records
- No database updates required
- Always shows current priority based on latest data

## Architecture

The package follows Salesforce best practices:
- **Declarative-first approach**: Flows, Assignment Rules, Formula Fields
- **No Apex required**: All business logic in configuration
- **Admin-friendly**: Point-and-click maintenance
- **Bulkified by platform**: Native features handle bulk operations
- **Governor limit friendly**: Platform features optimized by Salesforce
- **Upgrade-safe**: Less custom code = easier platform upgrades

## Why This Approach?

### Benefits of Declarative Development
1. **Easier Maintenance**: Admins can modify flows without developer assistance
2. **Lower TCO**: No code to maintain, debug, or rewrite
3. **Faster Delivery**: Build and deploy features more quickly
4. **Platform Upgrades**: Salesforce maintains and improves declarative features
5. **Better Performance**: Native features optimized by Salesforce engineering
6. **Reduced Testing**: Less custom code = fewer test classes required

### When to Use Custom Code
This package intentionally avoids custom Apex to demonstrate platform capabilities. Consider custom code only when:
- Platform features cannot meet the requirement
- Complex algorithms or calculations are needed
- External system integration requires custom callouts
- Bulk processing exceeds Flow limits (2000 records per transaction)

## Dependencies
This package has no external dependencies and can be installed independently.

## Troubleshooting

### Assignment Rules Not Working
- Verify rule is Active
- Check that criteria fields are populated on Lead
- Ensure users/queues referenced in rules exist in your org

### Flows Not Triggering
- Verify flows are Active (Setup > Flows)
- Check trigger criteria is met
- Review Flow history to see error messages

### Formula Field Shows Error
- Ensure all referenced fields exist
- Check field types match formula expectations
- Verify user has read access to all referenced fields

## Support
For issues or questions about this package, please refer to the main repository documentation or create an issue in the repository.

## Version History
- **v1.0.0**: Initial release with declarative automation features

## License
This package is provided as an educational resource for the Salesforce community.
