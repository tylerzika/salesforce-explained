# SalesProcessCore Package

## Overview

The **SalesProcessCore** package is a comprehensive Salesforce Sales Cloud solution that demonstrates best practices for managing core sales workflows. This package leverages standard Salesforce objects (Leads, Opportunities, Accounts, and Contacts) along with declarative features to create a robust sales process management system.

## Key Features

### 1. Record Types for International Support

The package includes Record Types to support different business processes:

#### Lead Record Types
- **North America Lead**: Optimized for leads from North American markets
- **International Lead**: Tailored for international market leads with regional considerations

#### Opportunity Record Types
- **Enterprise Opportunity**: For large-scale, complex enterprise deals
- **SMB Opportunity**: Streamlined process for small to medium business opportunities

### 2. Data Integrity with Validation Rules

Multiple validation rules ensure data quality throughout the sales process:

#### Lead Validations
- **Email Required for Converted Leads**: Ensures all converted leads have valid email addresses
- **Company Name Required**: Mandates company name for all lead records

#### Opportunity Validations
- **Close Date Must Be Future**: Prevents setting past dates for open opportunities
- **Amount Required for Closed Won**: Ensures closed won opportunities have valid amounts

### 3. Automated Workflows with Flow

#### Notify Sales Team on Key Activities
A record-triggered Flow that automatically notifies the sales team when opportunities reach critical stages:
- Proposal/Price Quote
- Negotiation/Review
- Closed Won

This Flow sends email notifications to opportunity owners, keeping them informed of important milestones.

#### Lead Conversion Notification
Automatically triggers when a lead is converted, performing the following actions:
- Creates a follow-up task for the opportunity owner
- Sends an email notification about the conversion
- Ensures smooth handoff from lead to opportunity management

### 4. Territory Management Support

The package is designed to work seamlessly with Salesforce Territory Management, enabling:
- Regional assignment of opportunities
- Automatic routing to appropriate sales representatives
- Territory-based reporting and analytics

## Package Contents

```
sales-process-core/
├── main/
│   └── default/
│       ├── objects/
│       │   ├── Lead/
│       │   │   ├── recordTypes/
│       │   │   │   ├── NorthAmericaLead.recordType-meta.xml
│       │   │   │   └── InternationalLead.recordType-meta.xml
│       │   │   └── validationRules/
│       │   │       ├── Email_Required_For_Converted_Leads.validationRule-meta.xml
│       │   │       └── Company_Name_Required.validationRule-meta.xml
│       │   └── Opportunity/
│       │       ├── recordTypes/
│       │       │   ├── Enterprise.recordType-meta.xml
│       │       │   └── SMB.recordType-meta.xml
│       │       └── validationRules/
│       │           ├── Close_Date_Must_Be_Future.validationRule-meta.xml
│       │           └── Amount_Required_For_Closed_Won.validationRule-meta.xml
│       └── flows/
│           ├── Notify_Sales_Team_on_Key_Activities.flow-meta.xml
│           └── Lead_Conversion_Notification.flow-meta.xml
└── README.md
```

## Deployment Instructions

### Prerequisites
- Salesforce CLI installed
- Dev Hub org enabled
- Sales Cloud features enabled in your org

### Deploy to a Scratch Org

1. **Create a scratch org:**
   ```bash
   sf org create scratch -f config/project-scratch-def.json -a SalesProcessCore-scratch -d 30
   ```

2. **Push the package to the scratch org:**
   ```bash
   sf project deploy start -d sales-process-core
   ```

3. **Open the scratch org:**
   ```bash
   sf org open -o SalesProcessCore-scratch
   ```

4. **Assign permissions (if needed):**
   - Navigate to Setup → Users → Permission Sets
   - Assign relevant permissions to test users

### Deploy to Sandbox or Production

1. **Authenticate to your target org:**
   ```bash
   sf org login web -a MyTargetOrg
   ```

2. **Deploy the package:**
   ```bash
   sf project deploy start -d sales-process-core -o MyTargetOrg
   ```

3. **Run deployment tests:**
   ```bash
   sf project deploy start -d sales-process-core -o MyTargetOrg --test-level RunLocalTests
   ```

## Configuration Steps After Deployment

### 1. Configure Opportunity Stages

Navigate to **Setup → Opportunity → Opportunity Stages** and configure stages with appropriate probabilities:

| Stage Name | Probability | Type |
|------------|-------------|------|
| Prospecting | 10% | Open |
| Qualification | 20% | Open |
| Needs Analysis | 30% | Open |
| Value Proposition | 40% | Open |
| Proposal/Price Quote | 60% | Open |
| Negotiation/Review | 80% | Open |
| Closed Won | 100% | Won |
| Closed Lost | 0% | Lost |

### 2. Activate Flows

1. Navigate to **Setup → Flows**
2. Locate and activate:
   - Notify Sales Team on Key Activities
   - Lead Conversion Notification

### 3. Configure Territory Management (Optional)

If using Territory Management:
1. Enable Territory Management 2.0
2. Define territory models based on geographical regions
3. Create assignment rules to auto-assign opportunities
4. Configure territory hierarchies

### 4. Set Up Record Type Assignments

Configure record type assignments for different user profiles:
1. Navigate to **Setup → Object Manager → Lead/Opportunity**
2. Select Record Types
3. Assign default record types to profiles

## Use Cases

### Enterprise Sales Teams
- Manage complex, multi-stage enterprise deals
- Track regional performance with territory management
- Ensure data quality with robust validation rules

### International Sales Operations
- Support different processes for various markets
- Localized lead and opportunity management
- Multi-currency and multi-language support

### Sales Management
- Automated notifications for critical opportunity stages
- Improved lead-to-opportunity conversion tracking
- Standardized sales processes across teams

## Benefits

1. **Improved Data Quality**: Validation rules prevent incomplete or invalid data
2. **Increased Efficiency**: Automated workflows reduce manual tasks
3. **Better Visibility**: Timely notifications keep sales teams informed
4. **Standardization**: Consistent processes across different sales segments
5. **Scalability**: Designed to support growing sales organizations
6. **Compliance**: Built-in data integrity supports audit and compliance requirements

## Best Practices Demonstrated

- **Declarative Development**: Maximizes use of clicks-not-code approach
- **Standard Object Usage**: Leverages out-of-the-box Sales Cloud capabilities
- **Process Automation**: Uses Flow for modern, maintainable automation
- **Data Integrity**: Implements validation rules for quality assurance
- **User Experience**: Provides timely notifications and automated task creation
- **Modular Design**: Package structure allows for easy deployment and maintenance

## Support and Feedback

This package is designed as an educational reference for implementing Sales Cloud solutions. For questions or feedback, please refer to the root repository README.md.

## Version History

- **v1.0.0**: Initial release with core sales process features
