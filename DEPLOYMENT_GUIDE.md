# Deployment Guide

This guide provides complete instructions for deploying the Salesforce Sales Cloud unlocked packages to different environments.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Package Overview](#package-overview)
3. [Scratch Org Deployment](#scratch-org-deployment)
4. [Sandbox Deployment](#sandbox-deployment)
5. [Production Deployment](#production-deployment)
6. [Post-Deployment Configuration](#post-deployment-configuration)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- **Salesforce CLI**: Version 2.0 or higher
  ```bash
  # Install Salesforce CLI
  npm install -g @salesforce/cli
  
  # Verify installation
  sf --version
  ```

- **Git**: For cloning the repository
  ```bash
  git --version
  ```

### Required Permissions

- Dev Hub enabled (for scratch orgs)
- System Administrator profile or equivalent
- API Enabled permission
- Deploy permission (Modify All Data or Customize Application)

### Salesforce Org Requirements

- Sales Cloud enabled
- API access enabled
- Sufficient user licenses
- Storage capacity for metadata

## Package Overview

### SalesProcessCore (Foundational)

**Size**: 10 metadata files  
**Complexity**: Medium  
**Dependencies**: None (standard objects only)  
**Deployment Time**: ~5 minutes

**Components**:
- 4 Record Types (2 Lead, 2 Opportunity)
- 4 Validation Rules (2 Lead, 2 Opportunity)
- 2 Flows (record-triggered automation)

### SalesDataIntegration (Advanced)

**Size**: 7 metadata files + setup required  
**Complexity**: Medium-High  
**Dependencies**: External API access  
**Deployment Time**: ~10 minutes + configuration

**Components**:
- 2 Named Credentials
- 2 Flows (API integration)
- 2 Reports
- 1 Dashboard

## Scratch Org Deployment

### Step 1: Clone Repository

```bash
git clone https://github.com/tylerzika/salesforce-explained.git
cd salesforce-explained
```

### Step 2: Create Scratch Org

```bash
# Create a 30-day scratch org
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias salescloud-demo \
  --duration-days 30 \
  --set-default

# Verify org creation
sf org list
```

### Step 3: Deploy SalesProcessCore

```bash
# Deploy the package
sf project deploy start \
  --source-dir sales-process-core \
  --wait 10

# Verify deployment
sf project deploy report
```

### Step 4: Deploy SalesDataIntegration

```bash
# Deploy the package
sf project deploy start \
  --source-dir sales-data-integration \
  --wait 10

# Note: Flows will need additional configuration
```

### Step 5: Open Scratch Org

```bash
sf org open
```

### Step 6: Post-Deployment Configuration

See [Post-Deployment Configuration](#post-deployment-configuration) section below.

## Sandbox Deployment

### Step 1: Authenticate to Sandbox

```bash
# Login to sandbox
sf org login web --alias mysandbox --instance-url https://test.salesforce.com

# Set as default org
sf config set target-org=mysandbox
```

### Step 2: Validate Deployment

```bash
# Validate without deploying (dry run)
sf project deploy start \
  --source-dir sales-process-core \
  --target-org mysandbox \
  --dry-run \
  --test-level NoTestRun

# Check validation results
sf project deploy report --target-org mysandbox
```

### Step 3: Deploy to Sandbox

```bash
# Deploy SalesProcessCore
sf project deploy start \
  --source-dir sales-process-core \
  --target-org mysandbox \
  --wait 10

# Deploy SalesDataIntegration
sf project deploy start \
  --source-dir sales-data-integration \
  --target-org mysandbox \
  --wait 10
```

### Step 4: Verify Deployment

```bash
# Check deployment status
sf org display --target-org mysandbox

# Open sandbox
sf org open --target-org mysandbox
```

## Production Deployment

### ⚠️ Important Production Considerations

1. **Always test in sandbox first**
2. **Schedule during maintenance window**
3. **Communicate with stakeholders**
4. **Have a rollback plan**
5. **Run tests before deployment**

### Step 1: Authenticate to Production

```bash
# Login to production
sf org login web --alias production --instance-url https://login.salesforce.com

# Verify you're connected to the correct org
sf org display --target-org production
```

### Step 2: Run Validation with Tests

```bash
# Validate SalesProcessCore with tests
sf project deploy start \
  --source-dir sales-process-core \
  --target-org production \
  --dry-run \
  --test-level RunLocalTests

# Validation ID will be returned - save it for quick deploy
```

### Step 3: Quick Deploy

```bash
# If validation passes, quick deploy using validation ID
sf project deploy quick \
  --job-id <VALIDATION_ID> \
  --target-org production
```

### Step 4: Deploy Second Package

```bash
# Deploy SalesDataIntegration
sf project deploy start \
  --source-dir sales-data-integration \
  --target-org production \
  --test-level RunLocalTests \
  --wait 10
```

### Step 5: Verify Production Deployment

1. Check deployment status in Setup
2. Verify metadata in the org
3. Test key workflows
4. Monitor for errors

## Post-Deployment Configuration

### For SalesProcessCore

#### 1. Activate Flows

```bash
# Open the org
sf org open

# Navigate to: Setup → Flows
# Activate these flows:
# - Lead Conversion Notification
# - Notify Sales Team on Key Activities
```

Manual steps:
1. Go to **Setup** → **Process Automation** → **Flows**
2. Click on **Lead Conversion Notification**
3. Click **Activate**
4. Repeat for **Notify Sales Team on Key Activities**

#### 2. Configure Opportunity Stages

1. Navigate to **Setup** → **Object Manager** → **Opportunity** → **Fields & Relationships**
2. Click on **Stage** field
3. Configure stage probabilities (see package README)

#### 3. Assign Record Types

1. Go to **Setup** → **Object Manager** → **Lead/Opportunity**
2. Click **Record Types**
3. Assign default record types to profiles
4. Configure record type visibility

### For SalesDataIntegration

#### 1. Configure Named Credentials

**Critical**: Update placeholder values!

1. Navigate to **Setup** → **Named Credentials**
2. Update **External Lead Source API**:
   - Replace endpoint URL
   - Update username
   - Set password
3. Update **Opportunity Data Service**:
   - Replace endpoint URL
   - Update username
   - Set password

#### 2. Register External Services

1. Navigate to **Setup** → **External Services**
2. Click **Add an External Service**
3. Import OpenAPI specification
4. Link to Named Credentials
5. Test connections

See [API_INTEGRATION_SETUP.md](./sales-data-integration/API_INTEGRATION_SETUP.md) for detailed instructions.

#### 3. Activate Flows

**Note**: Do not activate until External Services are configured!

1. Complete External Service registration first
2. Go to **Setup** → **Flows**
3. Activate flows only after External Services are ready

#### 4. Configure Reports and Dashboard

1. Navigate to **Reports** tab
2. Create folder: "Sales Integration Reports"
3. Move reports to folder
4. Set folder permissions
5. Open dashboard and configure running user

## Troubleshooting

### Common Deployment Issues

#### Issue: "Component Failures" During Deployment

**Symptoms**: Deployment fails with component errors

**Solutions**:
- Check API version compatibility (should be 65.0)
- Verify all required fields are present
- Review error messages for specific component issues

#### Issue: Named Credentials Fail to Save

**Symptoms**: Cannot save Named Credential configuration

**Solutions**:
- Verify endpoint URL is valid HTTPS
- Check username format
- Ensure password meets requirements
- Verify network connectivity from Salesforce

#### Issue: Flows Fail to Activate

**Symptoms**: Error when activating Flow

**Solutions**:
- For SalesDataIntegration: Ensure External Services are registered first
- Check all referenced fields exist
- Verify user has required permissions
- Review Flow error messages for specific issues

#### Issue: Validation Rules Block Records

**Symptoms**: Cannot create or update records

**Solutions**:
- Review validation rule logic
- Ensure required fields are populated
- Check field values meet criteria
- Temporarily deactivate for bulk imports (be careful!)

#### Issue: Reports Show No Data

**Symptoms**: Reports or Dashboard are empty

**Solutions**:
- Verify data exists with correct criteria
- Check report filters and date ranges
- Verify folder permissions
- Ensure running user has data access

#### Issue: API Connection Timeout

**Symptoms**: Flows fail with timeout errors

**Solutions**:
- Verify endpoint is accessible from Salesforce
- Check API response time
- Increase timeout settings if needed
- Verify API rate limits not exceeded

### Rollback Procedures

#### Rollback in Scratch Org

```bash
# Simply delete and recreate
sf org delete scratch --target-org salescloud-demo
```

#### Rollback in Sandbox/Production

**Option 1: Retrieve and Redeploy Previous Version**

```bash
# Retrieve current metadata
sf project retrieve start --target-org mysandbox

# Restore from backup/git
git checkout <previous-commit>

# Redeploy
sf project deploy start --source-dir sales-process-core
```

**Option 2: Manual Deactivation**

1. Deactivate Flows
2. Deactivate Validation Rules
3. Mark Record Types as inactive
4. Delete Reports and Dashboards

**Note**: Cannot delete Flows or Validation Rules, only deactivate.

### Getting Help

#### Deployment Logs

```bash
# View recent deployment logs
sf project deploy report --target-org <org-alias>

# View detailed logs
sf org display --target-org <org-alias> --verbose
```

#### Debug Mode

```bash
# Enable debug logs
sf org debug --target-org <org-alias>

# View logs
sf org tail log --target-org <org-alias>
```

#### Check Deployment Status

```bash
# List recent deployments
sf project deploy report --target-org <org-alias>

# Check specific deployment
sf project deploy report --job-id <deployment-id>
```

## Best Practices

### Pre-Deployment Checklist

- [ ] Backup current metadata
- [ ] Review all changes in sandbox
- [ ] Test with real data scenarios
- [ ] Verify user permissions
- [ ] Document changes
- [ ] Communicate to users
- [ ] Schedule maintenance window
- [ ] Prepare rollback plan

### During Deployment

- [ ] Monitor deployment progress
- [ ] Watch for errors in real-time
- [ ] Have technical team on standby
- [ ] Document any issues encountered

### Post-Deployment Checklist

- [ ] Verify all components deployed
- [ ] Activate Flows
- [ ] Configure Named Credentials
- [ ] Test key workflows
- [ ] Verify reports and dashboards
- [ ] Monitor for errors (24-48 hours)
- [ ] Gather user feedback
- [ ] Document lessons learned

## Additional Resources

- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Deployment Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_deploy.htm)
- [Package Development Model](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp.htm)
- Package-specific documentation:
  - [SalesProcessCore README](./sales-process-core/README.md)
  - [SalesDataIntegration README](./sales-data-integration/README.md)
  - [API Integration Setup](./sales-data-integration/API_INTEGRATION_SETUP.md)

## Support

For issues specific to these packages:
1. Check package-specific README files
2. Review troubleshooting section
3. Open an issue in the repository
4. Consult Salesforce documentation

---

**Last Updated**: January 2026  
**Package Version**: 1.0.0
