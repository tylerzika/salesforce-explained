# Salesforce Sales Cloud Best Practices Demo

An educational resource demonstrating out-of-the-box Salesforce Sales Cloud best practices and functionality for global sales operations. This project showcases declarative automation, standard Sales Cloud features, reporting, and international setup configurations.

## Overview

This Salesforce DX project provides a complete reference implementation of Sales Cloud best practices including:

- **Standard Lead Conversion**: Proper field mapping from Lead to Account, Contact, and Opportunity
- **Opportunity Management**: Configured stages with probability settings for accurate forecasting
- **Declarative Automation**: Record-triggered Flows and Approval Processes
- **Reports & Dashboards**: Pre-built analytics for pipeline visibility and sales performance
- **International Setup**: Multi-currency support and Territory Management for global operations

## Key Features

### 1. Lead Conversion with Field Mapping
- **Region field** on Lead, Account, and Opportunity objects
- Automatic field mapping during lead conversion
- Maintains regional data consistency across objects

### 2. Automated Follow-ups
- **Lead Conversion Follow-Up Flow**: Automatically creates a high-priority task for the opportunity owner when a lead is converted
- Ensures smooth handoff and customer engagement

### 3. Approval Processes
- **High Value Opportunity Approval**: Requires manager approval for opportunities exceeding $100,000
- Triggered at Negotiation/Review and Closed Won stages
- Enforces governance for large deals

### 4. Reports & Dashboards

#### Reports
- **Pipeline Value by Stage**: Visualizes open opportunities grouped by stage
- **Closed Won Deals by Region**: Analyzes won deals by geographic region
- **Lead Conversion Rate**: Tracks effectiveness of lead-to-opportunity conversion

#### Dashboard
- **Sales Performance Dashboard**: Comprehensive view with:
  - Total pipeline value metrics
  - Pipeline breakdown by stage (bar chart)
  - Closed won analysis by region (column chart)
  - Lead conversion rate (donut chart)
  - Top opportunities table

### 5. International Setup
- **Multi-Currency**: Enabled for tracking deals in multiple currencies
- **Territory Management**: Territory2 model with regional territories:
  - North America
  - Europe
  - Asia Pacific
  - Latin America
  - Middle East Africa
- **Forecasting**: Enabled for sales quota management

## Deployment Instructions

### Prerequisites
- Salesforce CLI installed ([Download](https://developer.salesforce.com/tools/sfdxcli))
- Dev Hub org enabled ([Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.htm))

### Deploy to a Scratch Org

1. **Clone the repository**
   ```bash
   git clone https://github.com/tylerzika/salesforce-explained.git
   cd salesforce-explained
   ```

2. **Authorize your Dev Hub**
   ```bash
   sf org login web --set-default-dev-hub
   ```

3. **Create a scratch org**
   ```bash
   sf org create scratch --definition-file config/project-scratch-def.json --alias sales-demo --duration-days 30 --set-default
   ```

4. **Push the source code**
   ```bash
   sf project deploy start
   ```

5. **Open the scratch org**
   ```bash
   sf org open
   ```

## Exploring the Functionality

### Testing Lead Conversion
1. Navigate to the **Leads** tab
2. Create a new Lead with:
   - Company name
   - Lead Status: "Working - Contacted"
   - Region: Select any region (e.g., "North America")
3. Click **Convert** on the Lead
4. Follow the standard conversion process
5. After conversion, check the newly created Opportunity for:
   - A follow-up Task assigned to the owner
   - Region field populated from the Lead

### Testing High Value Opportunity Approval
1. Create or edit an Opportunity
2. Set Amount to **$150,000** (above the $100k threshold)
3. Set Stage to **Negotiation/Review**
4. Submit the record for approval
5. View approval history and manager assignment

### Viewing Reports and Dashboard
1. Navigate to the **Reports** tab
2. Go to the **Sales Reports** folder
3. Run any of the pre-configured reports
4. Navigate to **Dashboards** tab
5. View the **Sales Performance Dashboard**

### Multi-Currency Setup
1. Go to **Setup** > **Company Information** > **Currency Setup**
2. Add additional active currencies (EUR, GBP, JPY, etc.)
3. Create Opportunities in different currencies
4. View reports with multi-currency amounts

### Territory Management
1. Go to **Setup** > **Territory Settings**
2. Enable Territory2 if not already active
3. View the **Global Sales Territories** model
4. Assign users to territories
5. Assign accounts to territories based on Region field

## Sales Cloud Best Practices Demonstrated

### Standard Salesforce Features
✅ Uses native Lead conversion without custom code  
✅ Leverages standard Opportunity stages and probabilities  
✅ Utilizes built-in forecasting capabilities  
✅ Implements Territory2 for regional alignment  

### Declarative Development
✅ Record-triggered Flow instead of Apex triggers  
✅ Approval Process for business rules enforcement  
✅ Standard field mapping for data consistency  

### Reporting & Analytics
✅ Summary reports with groupings and aggregations  
✅ Dashboard with multiple component types  
✅ Charts for visual pipeline analysis  

### International Operations
✅ Multi-currency for global deal tracking  
✅ Regional territories for geographic organization  
✅ Region fields for performance tracking  

## Use Cases

### Sales Manager
- Monitor pipeline health using the Sales Performance Dashboard
- Review closed-won deals by region for territory performance
- Approve high-value opportunities before closure

### Sales Representative
- Convert leads with automatic follow-up task creation
- Track opportunities through standard stages
- Submit large deals for manager approval

### Sales Operations
- Analyze lead conversion rates to optimize marketing
- Review pipeline distribution across stages
- Configure regional territories and currency settings

## Project Structure

```
force-app/main/default/
├── approvalProcesses/       # High Value Opportunity Approval
├── dashboards/              # Sales Performance Dashboard
├── flows/                   # Lead Conversion Follow-Up Flow
├── objects/                 # Custom fields (Region__c)
│   ├── Account/
│   ├── Lead/
│   └── Opportunity/
├── reports/                 # Sales Reports
└── territory2Models/        # Global Sales Territories
```

## Configuration Notes

### Opportunity Stages
The project uses standard Salesforce opportunity stages. Recommended probability settings:
- Prospecting: 10%
- Qualification: 20%
- Needs Analysis: 40%
- Value Proposition: 50%
- Proposal/Price Quote: 65%
- Negotiation/Review: 80%
- Closed Won: 100%
- Closed Lost: 0%

### Multi-Currency
After deployment, manually enable currencies in Setup:
1. Setup > Company Information > Currency Setup
2. Click "Manage Currencies"
3. Add: EUR, GBP, JPY, AUD (or others as needed)

### Territory Assignment Rules
Territory assignments should be configured based on:
- Account Region field
- Account billing address
- Custom territory logic

## Additional Resources

- [Salesforce Sales Cloud Documentation](https://help.salesforce.com/s/articleView?id=sf.sales_core.htm)
- [Territory Management Best Practices](https://help.salesforce.com/s/articleView?id=sf.tm2_implementation.htm)
- [Salesforce Flow Best Practices](https://help.salesforce.com/s/articleView?id=sf.flow_prep_bestpractices.htm)
- [Sales Cloud Setup Guide](https://trailhead.salesforce.com/content/learn/modules/sales_cloud_setup)

## Contributing

This is an educational resource. Feel free to fork and adapt for your own learning or demonstration purposes.

## License

See repository license for details.
