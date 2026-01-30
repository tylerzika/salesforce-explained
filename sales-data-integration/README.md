# SalesDataIntegration Package

## Overview

The **SalesDataIntegration** package demonstrates best practices for integrating external data sources with Salesforce Sales Cloud. This package showcases API integration patterns, data mapping strategies, and automated data synchronization using declarative tools and standard Salesforce features.

## ⚠️ Important Prerequisites

**Before deploying this package, please note:**

1. **External Service Setup Required**: The Flows in this package reference External Service actions that must be configured separately in your Salesforce org before the Flows can be activated.

2. **Named Credentials Configuration**: The Named Credentials included use placeholder values and must be updated with your actual API endpoints and credentials.

3. **API Access Needed**: You must have access to external APIs that follow the data structure described in the documentation.

**See the [API Integration Setup Guide](./API_INTEGRATION_SETUP.md) for detailed configuration instructions.**

## Key Features

### 1. External API Integration

The package includes Named Credentials for secure external system connectivity:

- **External Lead Source API**: Connects to external lead generation systems
- **Opportunity Data Service**: Integrates opportunity enrichment data from external sources

### 2. Automated Data Import Flows

#### Import External Leads
A scheduled Flow that:
- Calls external APIs to retrieve lead data
- Parses JSON responses
- Maps external data fields to Salesforce Lead fields
- Creates lead records automatically
- Handles bulk imports efficiently

#### Update Opportunity from External Data
A record-triggered Flow that:
- Activates when new opportunities are created
- Fetches additional context from external systems
- Enriches opportunity records with external data
- Maintains data synchronization

### 3. Reports and Dashboards

#### External API Leads Report
Tracks all leads imported from external sources:
- Filter by lead source (External API)
- Shows import dates and status
- Monitors lead quality and conversion

#### Integrated Opportunities Report
Monitors opportunities affected by data integration:
- Groups by stage
- Shows integration impact
- Tracks pipeline health

#### External Data Integration Dashboard
A comprehensive dashboard featuring:
- **Total External Leads Metric**: Last 30 days import count
- **Lead Conversion Funnel**: Visualizes conversion progress
- **Integration Success Rate**: Monitors data quality and success

### 4. API Documentation Support

The package includes detailed documentation for:
- Setting up Named Credentials
- Configuring External Services
- Testing API connections
- Troubleshooting integration issues

## Package Contents

```
sales-data-integration/
├── main/
│   └── default/
│       ├── namedCredentials/
│       │   ├── External_Lead_Source_API.namedCredential-meta.xml
│       │   └── Opportunity_Data_Service.namedCredential-meta.xml
│       ├── flows/
│       │   ├── Import_External_Leads.flow-meta.xml
│       │   └── Update_Opportunity_from_External_Data.flow-meta.xml
│       ├── reports/
│       │   ├── External_API_Leads.report-meta.xml
│       │   └── Integrated_Opportunities_Report.report-meta.xml
│       └── dashboards/
│           └── External_Data_Integration_Dashboard.dashboard-meta.xml
└── README.md
```

## Deployment Instructions

### Prerequisites
- Salesforce CLI installed
- Dev Hub org enabled
- Sales Cloud features enabled
- API access permissions configured

### Deploy to a Scratch Org

1. **Create a scratch org with API features:**
   ```bash
   sf org create scratch -f config/project-scratch-def.json -a SalesDataIntegration-scratch -d 30
   ```

2. **Push the package to the scratch org:**
   ```bash
   sf project deploy start -d sales-data-integration
   ```

3. **Open the scratch org:**
   ```bash
   sf org open -o SalesDataIntegration-scratch
   ```

### Deploy to Sandbox or Production

1. **Authenticate to your target org:**
   ```bash
   sf org login web -a MyTargetOrg
   ```

2. **Deploy the package:**
   ```bash
   sf project deploy start -d sales-data-integration -o MyTargetOrg
   ```

3. **Verify deployment:**
   ```bash
   sf project deploy report --target-org MyTargetOrg
   ```

## Configuration Steps After Deployment

### 1. Set Up Named Credentials

Named Credentials provide secure authentication to external services.

#### Configure External Lead Source API

1. Navigate to **Setup → Named Credentials**
2. Locate "External Lead Source API"
3. Update the endpoint URL to your actual API endpoint
4. Configure authentication:
   - **Authentication Protocol**: Password Authentication
   - **Username**: Your API username
   - **Password**: Your API password
   - **Identity Type**: Named Principal

#### Configure Opportunity Data Service

1. Navigate to **Setup → Named Credentials**
2. Locate "Opportunity Data Service"
3. Update endpoint and credentials similarly

**Best Practice**: Use OAuth 2.0 for production environments instead of password authentication.

### 2. Configure External Services (Optional)

For advanced API integration:

1. Navigate to **Setup → External Services**
2. Click "Add an External Service"
3. Import OpenAPI/Swagger specifications for your APIs
4. Configure service endpoints and schemas
5. Test the connection

### 3. Activate and Schedule Flows

#### Activate Import External Leads Flow

1. Navigate to **Setup → Flows**
2. Locate "Import External Leads"
3. Activate the flow
4. Schedule flow execution:
   - Click "Schedule"
   - Set frequency (e.g., Daily at 2 AM)
   - Specify start and end dates

#### Activate Update Opportunity Flow

1. Navigate to **Setup → Flows**
2. Locate "Update Opportunity from External Data"
3. Activate the flow (automatically triggered on Opportunity creation)

### 4. Configure Report Folders

1. Navigate to **Reports** tab
2. Create a folder: "Sales Integration Reports"
3. Move deployed reports to this folder
4. Set folder permissions for appropriate users

### 5. Set Up Dashboard Access

1. Navigate to **Dashboards** tab
2. Open "External Data Integration Dashboard"
3. Click "Properties"
4. Configure running user and sharing settings
5. Add to relevant Lightning pages or tabs

## API Integration Guide

### Preparing Your External APIs

Your external APIs should return data in JSON format. Example lead data structure:

```json
{
  "leads": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "company": "Acme Corp",
      "email": "john.doe@acme.com",
      "phone": "555-1234",
      "status": "New"
    }
  ]
}
```

### Testing API Connections

1. **Use Workbench or Developer Console:**
   ```apex
   HttpRequest req = new HttpRequest();
   req.setEndpoint('callout:External_Lead_Source_API');
   req.setMethod('GET');
   Http http = new Http();
   HttpResponse res = http.send(req);
   System.debug(res.getBody());
   ```

2. **Test in Flow:**
   - Create a test flow with debug mode
   - Call the external service action
   - Review debug logs for API responses

### Data Mapping Considerations

When mapping external data to Salesforce:

- **Required Fields**: Ensure external data includes Salesforce required fields
- **Picklist Values**: Map external values to Salesforce picklist options
- **Data Types**: Convert data types appropriately (dates, numbers, etc.)
- **Duplicates**: Implement duplicate checking logic
- **Error Handling**: Add decision elements to handle API failures

## Use Cases

### Marketing Automation Integration
- Import leads from marketing platforms (HubSpot, Marketo, Pardot)
- Sync lead scoring and engagement data
- Track multi-channel attribution

### Lead Generation Services
- Integrate with lead providers (ZoomInfo, LinkedIn Sales Navigator)
- Automatically enrich lead data
- Maintain up-to-date contact information

### Opportunity Intelligence
- Pull competitive intelligence from external sources
- Enrich opportunities with market data
- Integrate with product catalogs or pricing engines

### Data Warehousing
- Sync opportunities to external analytics platforms
- Enable cross-system reporting
- Support data lake architectures

## Benefits

1. **Automation**: Reduces manual data entry and increases productivity
2. **Data Accuracy**: Automated imports reduce human error
3. **Real-Time Insights**: Fresh data enables better decision-making
4. **Scalability**: Handle large volumes of data efficiently
5. **Integration**: Seamlessly connects Salesforce with external ecosystems
6. **Visibility**: Reports and dashboards track integration health

## Best Practices Demonstrated

- **Named Credentials**: Secure, manageable authentication
- **Declarative Integration**: Uses Flow instead of custom Apex code
- **Error Handling**: Includes decision logic for failure scenarios
- **Monitoring**: Reports and dashboards for operational visibility
- **Modular Design**: Separate flows for different integration points
- **API-First Approach**: Leverages standard APIs and External Services
- **Security**: Follows Salesforce security best practices

## Troubleshooting

### Common Issues

**Issue**: Named Credential authentication fails
- **Solution**: Verify endpoint URL, credentials, and network connectivity
- Check for certificate errors or firewall restrictions

**Issue**: Flow fails to create leads
- **Solution**: Review debug logs for API response errors
- Verify required fields are mapped correctly
- Check user permissions for lead creation

**Issue**: Dashboard shows no data
- **Solution**: Ensure leads are marked with "External API" source
- Verify report filters and date ranges
- Check dashboard running user permissions

**Issue**: API rate limits exceeded
- **Solution**: Adjust flow schedule frequency
- Implement batch processing for large data volumes
- Contact API provider for rate limit increases

## Monitoring and Maintenance

### Regular Checks

1. **Daily**: Review dashboard metrics for anomalies
2. **Weekly**: Check integration error logs
3. **Monthly**: Audit Named Credential access
4. **Quarterly**: Review API usage and costs

### Performance Optimization

- Monitor flow execution times
- Optimize API payloads to reduce data transfer
- Use bulk APIs for large data volumes
- Implement caching strategies where appropriate

## Security Considerations

- Store API credentials securely using Named Credentials
- Use HTTPS endpoints only
- Implement IP restrictions where possible
- Regular credential rotation
- Audit trail for data access
- Encrypt sensitive data in transit and at rest

## Support and Feedback

This package is designed as an educational reference for implementing Salesforce API integrations. For questions or feedback, please refer to the root repository README.md.

## Future Enhancements

Potential additions for future versions:
- Bi-directional sync capabilities
- Change Data Capture integration
- Platform Events for real-time integration
- Custom Apex for complex transformations
- Integration with Einstein Analytics

## Version History

- **v1.0.0**: Initial release with core integration features
