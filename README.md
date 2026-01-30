# Salesforce Sales Cloud Unlocked Packages

This repository contains two comprehensive unlocked packages demonstrating Salesforce Sales Cloud best practices, combining standard objects, declarative automation, and real-world integration patterns.

## 📦 Packages Overview

### 1. SalesProcessCore

A robust sales workflow management package that showcases backend logic for standard Sales Cloud objects.

**Key Capabilities:**
- ✅ Lead and Opportunity management with Record Types
- ✅ Data integrity through Validation Rules
- ✅ Automated notifications via record-triggered Flows
- ✅ Territory Management support
- ✅ Multi-stage opportunity tracking with probability settings

**Best For:** Organizations looking to standardize sales processes, improve data quality, and automate sales team workflows.

[📖 View SalesProcessCore Documentation](./sales-process-core/README.md)

### 2. SalesDataIntegration

An API integration package demonstrating data mapping and synchronization between external systems and Salesforce.

**Key Capabilities:**
- ✅ External API integration via Named Credentials
- ✅ Automated lead import flows
- ✅ Opportunity enrichment from external data
- ✅ Integration monitoring reports and dashboards
- ✅ Declarative data mapping patterns

**Best For:** Organizations integrating Salesforce with marketing automation, lead providers, or custom external systems.

[📖 View SalesDataIntegration Documentation](./sales-data-integration/README.md)

## 🎯 Purpose

These packages serve as **educational references** for implementing Salesforce Sales Cloud solutions that:
- Leverage out-of-the-box capabilities
- Follow Salesforce best practices
- Demonstrate declarative development approaches
- Solve real-world business challenges

## 🏗️ Architecture

Both packages follow Salesforce's recommended architecture patterns:

### Modular Design
- Independent packages with clear separation of concerns
- Each package can be deployed separately
- Minimal dependencies between packages

### Declarative-First Approach
- Maximizes use of clicks-not-code
- Uses Flow for automation (not Process Builder or Workflow Rules)
- Leverages standard objects and features

### API Integration Standards
- Named Credentials for secure authentication
- External Services for API consumption
- Standardized error handling and monitoring

## 🚀 Quick Start

### Prerequisites

- Salesforce CLI installed ([Install Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm))
- Dev Hub enabled in your Salesforce org
- Git installed on your machine

### Clone the Repository

```bash
git clone https://github.com/tylerzika/salesforce-explained.git
cd salesforce-explained
```

### Deploy Both Packages to a Scratch Org

```bash
# Create a scratch org
sf org create scratch -f config/project-scratch-def.json -a MyScratchOrg -d 30

# Deploy SalesProcessCore
sf project deploy start -d sales-process-core -o MyScratchOrg

# Deploy SalesDataIntegration
sf project deploy start -d sales-data-integration -o MyScratchOrg

# Open the scratch org
sf org open -o MyScratchOrg
```

### Deploy to Sandbox or Production

```bash
# Authenticate to your target org
sf org login web -a MyTargetOrg

# Deploy packages
sf project deploy start -d sales-process-core -o MyTargetOrg
sf project deploy start -d sales-data-integration -o MyTargetOrg
```

## 📚 Salesforce Best Practices Demonstrated

### 1. Standard Object Utilization
Both packages maximize use of standard Sales Cloud objects (Lead, Opportunity, Account, Contact) rather than creating custom objects unnecessarily.

### 2. Record Types for Process Variation
Different business processes (Enterprise vs SMB, North America vs International) are handled through Record Types, not separate objects.

### 3. Validation Rules for Data Quality
Ensures data integrity at the platform level, preventing bad data from entering the system regardless of entry point.

### 4. Flow for Modern Automation
Uses Flow (not deprecated Workflow Rules or Process Builder) for all automation, ensuring long-term maintainability.

### 5. Named Credentials for Security
API credentials are stored securely using Named Credentials, not hardcoded in code or stored in custom settings.

### 6. Reports and Dashboards for Visibility
Pre-built analytics components provide immediate value and demonstrate operational monitoring patterns.

### 7. Modular Package Structure
Clear separation of concerns allows for independent deployment, versioning, and maintenance.

### 8. Territory Management Alignment
Designed to work with Salesforce Territory Management 2.0 for enterprise-scale deployments.

## 🔧 Configuration

After deploying the packages, follow these configuration steps:

### For SalesProcessCore:
1. Configure Opportunity Stages with appropriate probabilities
2. Activate the included Flows
3. Set up Territory Management (if applicable)
4. Assign Record Types to user profiles

Detailed instructions: [SalesProcessCore Configuration](./sales-process-core/README.md#configuration-steps-after-deployment)

### For SalesDataIntegration:
1. Update Named Credentials with actual API endpoints
2. Configure authentication credentials
3. Activate and schedule Flows
4. Set up dashboard access and permissions

Detailed instructions: [SalesDataIntegration Configuration](./sales-data-integration/README.md#configuration-steps-after-deployment)

## 🎓 Learning Objectives

By exploring these packages, you'll learn:

- How to structure unlocked packages for Salesforce
- Best practices for Sales Cloud implementation
- Declarative automation patterns with Flow
- API integration without custom Apex code
- Data quality management techniques
- Territory and process management strategies

## 📊 Package Comparison

| Feature | SalesProcessCore | SalesDataIntegration |
|---------|------------------|----------------------|
| **Focus** | Sales Workflows | API Integration |
| **Objects** | Lead, Opportunity | Lead, Opportunity |
| **Automation** | Record-triggered Flows | Scheduled & Record Flows |
| **Integration** | Internal processes | External APIs |
| **Use Case** | Process standardization | Data synchronization |
| **Complexity** | Medium | Medium-High |

## 🛠️ Development Workflow

### Making Changes

1. Create a feature branch
2. Modify package metadata
3. Test in a scratch org
4. Deploy to sandbox for QA
5. Deploy to production

### Version Management

Both packages use semantic versioning:
- Major version: Breaking changes
- Minor version: New features, backward compatible
- Patch version: Bug fixes

Update versions in `sfdx-project.json`:
```json
{
  "versionNumber": "1.1.0.NEXT"
}
```

## 📖 Additional Resources

### Salesforce Documentation
- [Sales Cloud Basics](https://help.salesforce.com/s/articleView?id=sf.sales_core_overview.htm)
- [Flow Builder Guide](https://help.salesforce.com/s/articleView?id=sf.flow.htm)
- [Unlocked Packages](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_unlocked_pkg_intro.htm)
- [Named Credentials](https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm)

### Trailhead Modules
- [Sales Cloud for Admins](https://trailhead.salesforce.com/content/learn/trails/sales-admin)
- [Flow Basics](https://trailhead.salesforce.com/content/learn/modules/flow-basics)
- [API Integration Patterns](https://trailhead.salesforce.com/content/learn/modules/api_basics)

## 🤝 Contributing

This is an educational project. Contributions that improve documentation, add features, or fix issues are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is provided as-is for educational purposes. See LICENSE file for details.

## ⚠️ Disclaimer

These packages are designed as learning resources and demonstrations. Before deploying to production:
- Review all metadata for your specific requirements
- Test thoroughly in a sandbox environment
- Adjust validation rules, flows, and integrations for your use case
- Ensure compliance with your organization's security and governance policies

## 📞 Support

For issues or questions:
1. Check the package-specific README files
2. Review Salesforce documentation
3. Open an issue in this repository

---

**Built with ❤️ for the Salesforce community**
