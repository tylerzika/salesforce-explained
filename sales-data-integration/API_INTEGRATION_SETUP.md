# API Integration Setup Guide

This guide provides step-by-step instructions for setting up API integration with external systems for the SalesDataIntegration package.

## Prerequisites

Before setting up the integration:
- Admin access to your Salesforce org
- API credentials from your external systems
- Understanding of your external API endpoints

## Named Credentials Setup

### Step 1: Access Named Credentials

1. Log in to Salesforce
2. Navigate to **Setup** → **Security** → **Named Credentials**
3. You should see the deployed Named Credentials:
   - External Lead Source API
   - Opportunity Data Service

### Step 2: Configure External Lead Source API

1. Click on **External Lead Source API**
2. Click **Edit**
3. Update the following fields:

   | Field | Value | Description |
   |-------|-------|-------------|
   | Label | External Lead Source API | Display name |
   | Name | External_Lead_Source_API | API name |
   | URL | `https://api.yourservice.com/leads` | Your API endpoint |
   | Identity Type | Named Principal | Authentication method |
   | Authentication Protocol | Password | Auth type |
   | Username | your-api-username | API username |
   | Password | **************** | API password |

4. Click **Save**

### Step 3: Configure Opportunity Data Service

Repeat the same process for the Opportunity Data Service Named Credential.

## Testing Named Credentials

### Using Developer Console

1. Open **Developer Console** (Setup → Developer Console)
2. Click **Debug** → **Open Execute Anonymous Window**
3. Execute the following code:

```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:External_Lead_Source_API');
req.setMethod('GET');
Http http = new Http();
HttpResponse res = http.send(req);
System.debug('Status Code: ' + res.getStatusCode());
System.debug('Response Body: ' + res.getBody());
```

4. Check the debug logs for the response

### Expected Response Format

Your API should return JSON in the following format:

```json
{
  "leads": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "company": "Acme Corporation",
      "email": "john.doe@acme.com",
      "phone": "555-1234",
      "country": "USA"
    }
  ]
}
```

## Flow Configuration

### Activate Import External Leads Flow

1. Navigate to **Setup** → **Flows**
2. Search for "Import External Leads"
3. Click on the flow
4. Click **Activate**
5. To schedule the flow:
   - Click the **Schedule** button
   - Set frequency: **Daily**
   - Set time: **2:00 AM** (or preferred time)
   - Set start date
   - Click **Done**

### Activate Update Opportunity Flow

1. Navigate to **Setup** → **Flows**
2. Search for "Update Opportunity from External Data"
3. Click on the flow
4. Click **Activate**

This flow runs automatically when opportunities are created.

## External Services (Advanced)

For more complex integrations, you can use External Services:

### Step 1: Prepare OpenAPI Specification

Create an OpenAPI 3.0 specification for your API:

```yaml
openapi: 3.0.0
info:
  title: Lead Source API
  version: 1.0.0
servers:
  - url: https://api.yourservice.com
paths:
  /leads:
    get:
      summary: Get leads
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  leads:
                    type: array
                    items:
                      type: object
                      properties:
                        firstName:
                          type: string
                        lastName:
                          type: string
                        company:
                          type: string
                        email:
                          type: string
```

### Step 2: Register External Service

1. Navigate to **Setup** → **External Services**
2. Click **Add an External Service**
3. Enter a name: "Lead Source Service"
4. Upload or paste your OpenAPI spec
5. Select the Named Credential: **External_Lead_Source_API**
6. Click **Save & Next**
7. Review the generated schema
8. Click **Done**

### Step 3: Use in Flow

The External Service actions can now be used in Flow Builder:
1. Edit "Import External Leads" flow
2. Add an Action element
3. Search for your External Service
4. Configure the action
5. Map response fields to Salesforce fields

## Data Mapping

### Lead Field Mapping

| External Field | Salesforce Field | Required | Notes |
|----------------|------------------|----------|-------|
| firstName | FirstName | No | |
| lastName | LastName | Yes | |
| company | Company | Yes | Required by validation |
| email | Email | Recommended | Required for conversion |
| phone | Phone | No | |
| country | Country | No | |
| status | Status | No | Defaults to "Open - Not Contacted" |

### Opportunity Field Mapping

| External Field | Salesforce Field | Required | Notes |
|----------------|------------------|----------|-------|
| name | Name | Yes | |
| amount | Amount | Yes | Required for closed won |
| description | Description | No | |
| stage | StageName | Yes | |
| closeDate | CloseDate | Yes | Must be future date |

## Monitoring Integration

### Check Flow Execution

1. Navigate to **Setup** → **Flows**
2. Click on "Import External Leads"
3. Click **View Runs**
4. Review successful and failed runs
5. Click on individual runs to see details

### Review Debug Logs

1. Navigate to **Setup** → **Debug Logs**
2. Click **New**
3. Select a user and set log levels
4. Trigger the integration
5. Review the generated logs

### Monitor with Dashboard

1. Navigate to the **Dashboards** tab
2. Open "External Data Integration Dashboard"
3. Review metrics:
   - Total External Leads
   - Lead Conversion Funnel
   - Integration Success Rate

## Error Handling

### Common Errors and Solutions

#### Error: "Unauthorized" (401)

**Cause**: Invalid credentials or expired token

**Solution**:
1. Verify Named Credential username and password
2. Check if API token has expired
3. Verify endpoint URL is correct

#### Error: "Invalid Field" in Flow

**Cause**: Field mapping mismatch

**Solution**:
1. Review API response structure
2. Update Flow field mappings
3. Add decision elements for null checks

#### Error: "REQUIRED_FIELD_MISSING"

**Cause**: Required Salesforce fields not provided

**Solution**:
1. Ensure external API provides all required fields
2. Add default values in Flow
3. Update validation rules if needed

#### Error: "API_LIMIT_EXCEEDED"

**Cause**: API rate limit reached

**Solution**:
1. Reduce Flow execution frequency
2. Implement batch processing
3. Contact API provider for limit increase

## Security Best Practices

1. **Use Named Credentials**: Never hardcode credentials
2. **HTTPS Only**: Always use secure endpoints
3. **Rotate Credentials**: Change passwords regularly
4. **Minimum Permissions**: Grant only necessary API permissions
5. **IP Restrictions**: Whitelist Salesforce IPs in your API
6. **Audit Trails**: Enable logging for all API calls
7. **Data Encryption**: Ensure data is encrypted in transit

## Performance Optimization

1. **Bulk Processing**: Process records in batches
2. **Selective Fields**: Request only needed fields from API
3. **Caching**: Implement caching for frequently accessed data
4. **Async Processing**: Use scheduled flows for large volumes
5. **Timeout Settings**: Configure appropriate timeout values

## Testing Checklist

- [ ] Named Credentials authenticate successfully
- [ ] API returns expected data format
- [ ] Flows activate without errors
- [ ] Lead records are created correctly
- [ ] Opportunity updates work as expected
- [ ] Required fields are populated
- [ ] Validation rules pass
- [ ] Dashboard displays data
- [ ] Reports show correct results
- [ ] Error handling works properly

## Support Resources

- Salesforce Named Credentials: https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm
- External Services: https://help.salesforce.com/s/articleView?id=sf.external_services_about.htm
- Flow Best Practices: https://help.salesforce.com/s/articleView?id=sf.flow_prep_bestpractices.htm
- API Integration Patterns: https://developer.salesforce.com/docs/atlas.en-us.integration_patterns_and_practices.meta/integration_patterns_and_practices/

## Next Steps

After completing this setup:
1. Test the integration in a sandbox environment
2. Monitor for 1-2 weeks before production deployment
3. Train users on new data sources
4. Document any customizations
5. Set up alerts for integration failures
