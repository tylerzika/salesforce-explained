# Deployment Guide

This guide provides step-by-step instructions for deploying the Salesforce Sales Cloud Best Practices demo to your org.

## Prerequisites

Before deploying, ensure you have:

1. **Salesforce CLI** installed ([Download](https://developer.salesforce.com/tools/sfdxcli))
2. **Dev Hub** enabled in your Salesforce org
3. **Git** installed on your machine

## Option 1: Deploy to a Scratch Org (Recommended for Testing)

This is the recommended approach for exploring the functionality without affecting existing orgs.

### Step 1: Clone the Repository
```bash
git clone https://github.com/tylerzika/salesforce-explained.git
cd salesforce-explained
```

### Step 2: Authenticate with Dev Hub
```bash
sf org login web --set-default-dev-hub --alias myDevHub
```

### Step 3: Create a Scratch Org
```bash
sf org create scratch --definition-file config/project-scratch-def.json \
  --alias sales-demo \
  --duration-days 30 \
  --set-default
```

The scratch org will be created with:
- Multi-currency enabled
- Territory Management 2.0 enabled
- Forecasting enabled
- Sales Cloud features activated

### Step 4: Deploy the Metadata
```bash
sf project deploy start --source-path force-app
```

### Step 5: Open the Org
```bash
sf org open
```

### Step 6: Complete Post-Deployment Setup

After deployment, complete these manual configuration steps:

#### Enable Additional Currencies
1. Go to **Setup** > **Company Information** > **Manage Currencies**
2. Click **New** to add currencies:
   - EUR (Euro)
   - GBP (British Pound)
   - JPY (Japanese Yen)
   - AUD (Australian Dollar)
3. Set conversion rates for each currency

#### Activate Territory Model (if needed)
1. Go to **Setup** > **Territory Settings**
2. Enable **Enterprise Territory Management** if prompted
3. Navigate to **Territory Models**
4. Find **Global Sales Territories** model
5. Click **Deploy** to activate the model

#### Configure Approval Process Email
1. Go to **Setup** > **Email Addresses**
2. Verify your email address for approval notifications
3. Go to **Approval Processes**
4. Edit **High Value Opportunity Approval**
5. Update email template selection if needed

### Step 7: Load Sample Data (Optional)

To fully test the functionality, load sample data:

```bash
# Create sample accounts
sf data create record --sobject Account --values "Name='ACME Corp' Region__c='North America'"
sf data create record --sobject Account --values "Name='Global Industries' Region__c='Europe'"
sf data create record --sobject Account --values "Name='Pacific Trading' Region__c='Asia Pacific'"

# Create sample leads
sf data create record --sobject Lead --values "FirstName='John' LastName='Doe' Company='Test Corp' Status='Open - Not Contacted' Region__c='North America'"
sf data create record --sobject Lead --values "FirstName='Jane' LastName='Smith' Company='Sample Inc' Status='Open - Not Contacted' Region__c='Europe'"
```

## Option 2: Deploy to a Sandbox

For testing in a sandbox environment:

### Step 1: Authenticate with Sandbox
```bash
sf org login web --alias mySandbox --instance-url https://test.salesforce.com
```

### Step 2: Deploy the Metadata
```bash
sf project deploy start --source-path force-app --target-org mySandbox
```

### Step 3: Complete Post-Deployment Setup
Follow steps 6 from Option 1 above.

## Option 3: Deploy to Production (Not Recommended)

**Warning**: Only deploy to production after thorough testing in a sandbox environment.

### Prerequisites
- All code must have test coverage (N/A for this declarative solution)
- Change Set or deployment must be reviewed and approved
- Backup your data before deployment

### Step 1: Authenticate with Production
```bash
sf org login web --alias myProd
```

### Step 2: Validate the Deployment First
```bash
sf project deploy start --source-path force-app --target-org myProd --dry-run
```

### Step 3: Deploy if Validation Passes
```bash
sf project deploy start --source-path force-app --target-org myProd
```

### Step 4: Complete Post-Deployment Setup
Follow steps 6 from Option 1 above.

## Troubleshooting

### Common Issues

#### Issue: "Entity is not api-accessible"
**Solution**: Ensure your org has the required features enabled (Sales Cloud, Territory Management, Multi-Currency)

#### Issue: Approval Process Won't Activate
**Solution**: Ensure you have at least one active user with a manager assigned in the user hierarchy

#### Issue: Territory Model Won't Deploy
**Solution**: Territory2 models require manual activation after deployment. Follow the post-deployment steps above.

#### Issue: Reports Show No Data
**Solution**: Create sample data or wait for real data to populate. Reports require existing records to display.

#### Issue: Dashboard Components Show Errors
**Solution**: Ensure all reports are accessible and have run at least once. Check folder permissions.

### Getting Help

If you encounter issues:
1. Check the [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
2. Review [Sales Cloud Documentation](https://help.salesforce.com/s/articleView?id=sf.sales_core.htm)
3. Post questions on [Salesforce StackExchange](https://salesforce.stackexchange.com/)

## Uninstalling

To remove the components from your org:

### From Scratch Org
Simply delete the scratch org:
```bash
sf org delete scratch --target-org sales-demo
```

### From Sandbox or Production
1. Deactivate the Flow: **Lead_Conversion_Follow_Up**
2. Deactivate the Approval Process: **High_Value_Opportunity_Approval**
3. Delete the Territory Model: **Global_Sales_Territories**
4. Delete the Dashboard: **Sales Performance Dashboard**
5. Delete all Reports in **Sales_Reports** folder
6. Delete custom fields: **Region__c** from Lead, Account, and Opportunity

## Next Steps

After successful deployment:
1. Review the [README.md](README.md) for functionality overview
2. Test lead conversion with the sample data
3. Submit a high-value opportunity for approval
4. Explore reports and dashboards
5. Configure additional territories as needed

## Deployment Checklist

- [ ] Dev Hub authorized
- [ ] Scratch org created successfully
- [ ] Metadata deployed without errors
- [ ] Additional currencies activated
- [ ] Territory model deployed and activated
- [ ] Approval process tested with sample data
- [ ] Flow tested with lead conversion
- [ ] Reports display data correctly
- [ ] Dashboard components load properly
- [ ] Sample data created (optional)

Congratulations! Your Sales Cloud Best Practices demo is now deployed and ready to explore.
