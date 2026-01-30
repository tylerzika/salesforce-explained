# SalesInsightsUI Package

## Overview
The **SalesInsightsUI** package provides user interface components and reporting capabilities for visualizing international sales performance. This package complements the GlobalSalesCore package by offering interactive dashboards, heatmaps, and pre-configured reports designed for global sales operations.

## Features

### Lightning Web Components

#### Regional Dashboard (regionalDashboard)
An interactive dashboard component that displays key sales metrics by region:
- **Region Selector**: Filter data by specific regions (North America, EMEA, APAC, LATAM) or view all regions
- **Key Metrics Displayed**:
  - Quota vs. Actual Revenue
  - Quota Attainment Percentage (color-coded by performance)
  - Pipeline Value
  - Open Opportunities Count
  - Closed Won Opportunities Count
- **Visual Indicators**: Color-coded attainment percentages (green for 90%+, default for 70-89%, red for <70%)
- **Responsive Design**: Adapts to different screen sizes and devices

**Usage**: Can be added to App Pages, Home Pages, or Record Pages via Lightning App Builder

#### Opportunity Heatmap (opportunityHeatmap)
A visual heatmap component that shows opportunity distribution across regions and stages:
- **Metric Selection**: Toggle between Amount, Count, or Win Rate views
- **Heat Intensity**: Color-coded cells showing relative performance (light to dark blue)
- **Grid Layout**: Regions (rows) × Opportunity Stages (columns)
- **Interactive Legend**: Visual guide to understand heat intensity levels
- **Responsive Design**: Optimized for desktop and mobile viewing

**Usage**: Can be added to App Pages, Home Pages, or Record Pages via Lightning App Builder

### Pre-Configured Reports

#### Regional Opportunity Pipeline
- **Type**: Summary Report with Grouping
- **Purpose**: Analyze open opportunity pipeline by sales region
- **Key Metrics**:
  - Opportunity Count per region
  - Total Pipeline Amount per region
- **Filters**: 
  - Excludes Closed Won and Closed Lost opportunities
  - Shows opportunities with >0% probability
  - Current fiscal period close dates
- **Grouping**: By Sales Region custom field

#### Regional Revenue Performance
- **Type**: Summary Report with Chart
- **Purpose**: Track closed won revenue by region
- **Key Metrics**:
  - Win Count per region
  - Total Revenue per region
- **Visualization**: Horizontal bar chart showing revenue by region
- **Filters**:
  - Only Closed Won opportunities
  - Current fiscal period close dates
- **Grouping**: By Sales Region custom field

### Lightning App Page

#### Global Sales Insights
A custom Lightning App Page combining all UI components:
- **Layout**: Two-column header template
- **Components Included**:
  - Regional Dashboard (top section)
  - Opportunity Heatmap (bottom section)
- **Purpose**: Centralized view for sales executives and managers to monitor global performance
- **Responsive**: Automatically adjusts to screen size

## Installation

### Prerequisites
- Salesforce org with Sales Cloud enabled
- **GlobalSalesCore package must be installed first** (this package depends on it)
- API version 65.0 or higher
- Lightning Experience enabled
- System Administrator access

### Deployment Steps

1. **Ensure GlobalSalesCore is Installed**
   ```bash
   # Verify GlobalSalesCore is deployed
   sf package installed list --target-org myorg
   ```

2. **Using Salesforce CLI**
   ```bash
   # Authenticate to your org
   sf org login web --alias myorg

   # Create the package
   sf package create --name "SalesInsightsUI" --description "UI components for global sales insights" --package-type Unlocked --path packages/SalesInsightsUI

   # Create a package version
   sf package version create --package SalesInsightsUI --installation-key-bypass --wait 10

   # Install the package version
   sf package install --package 04t... --target-org myorg --wait 10
   ```

3. **Manual Deployment**
   ```bash
   sf project deploy start --source-dir packages/SalesInsightsUI --target-org myorg
   ```

## Configuration

### Post-Installation Steps

1. **Add Components to Pages**
   - Navigate to Lightning App Builder
   - Edit desired App Page or Home Page
   - Drag and drop "Regional Dashboard" and "Opportunity Heatmap" components
   - Configure component properties if needed
   - Save and activate the page

2. **Set Up Global Sales Insights Page**
   - Navigate to App Manager
   - Edit your Sales app
   - Add "Global Sales Insights" page to the app navigation
   - Set as default home page (optional)

3. **Configure Reports**
   - Navigate to Reports tab
   - Find "GlobalSalesReports" folder
   - Customize reports as needed for your org:
     - Adjust time frames
     - Add additional filters
     - Modify chart types
   - Save reports to accessible folders

4. **Create Dashboards** (Optional)
   - Create a new dashboard
   - Add report components:
     - Regional Opportunity Pipeline
     - Regional Revenue Performance
   - Add LWC components:
     - Regional Dashboard
     - Opportunity Heatmap
   - Share dashboard with appropriate users

5. **Set Up User Access**
   - Ensure users have access to:
     - Opportunity object
     - Custom fields from GlobalSalesCore package
     - Reports folder
     - Lightning pages

## Usage Examples

### Viewing Regional Performance
1. Navigate to the Global Sales Insights page
2. Use the region selector in the Regional Dashboard to filter by specific region
3. Review key metrics: quota, actual revenue, attainment percentage
4. Scroll down to view the Opportunity Heatmap for stage distribution

### Analyzing Pipeline by Region
1. Go to Reports tab
2. Open "Regional Opportunity Pipeline" report
3. Review the summary of opportunities grouped by region
4. Export or schedule the report as needed

### Monitoring Revenue Performance
1. Go to Reports tab
2. Open "Regional Revenue Performance" report
3. Review the horizontal bar chart showing revenue by region
4. Drill down into specific opportunities if needed

## Component Properties

### Regional Dashboard
- **title** (String): Dashboard title displayed in the card header
  - Default: "Regional Sales Dashboard"
  - Configurable: Yes

### Opportunity Heatmap
- **title** (String): Heatmap title displayed in the card header
  - Default: "Opportunity Heatmap"
  - Configurable: Yes

## Customization

### Extending the Components

#### Adding Real Data to Components
The components currently use mock data for demonstration. To connect to real Salesforce data:

1. Create Apex classes to query opportunities and regional quotas
2. Wire the Apex methods to the LWC components
3. Update the component logic to process real data

Example Apex method:
```apex
@AuraEnabled(cacheable=true)
public static List<OpportunityData> getRegionalOpportunities(String region) {
    // Query and return opportunity data
}
```

#### Customizing Metrics
To add or modify metrics in the components:
1. Update the component's JavaScript file
2. Add new properties to track additional metrics
3. Update the HTML template to display new metrics
4. Modify CSS for styling as needed

### Modifying Reports
- Use the Report Builder to add/remove fields
- Change groupings and filters
- Add calculated fields using formulas
- Change chart types and colors

## Architecture

The package follows Salesforce best practices:
- **Component-based architecture**: Modular LWC components
- **Reactive programming**: Uses @track and @wire decorators
- **Lightning Design System**: Consistent styling and accessibility
- **Responsive design**: Mobile-first approach
- **Performance optimization**: Efficient rendering and data handling

## Dependencies
This package depends on **GlobalSalesCore** package:
- Custom fields: SalesRegion__c, ForecastCategory__c
- Custom objects: RegionalQuota__c
- The metadata relationship is defined in sfdx-project.json

## Browser Support
- Google Chrome (recommended)
- Mozilla Firefox
- Microsoft Edge
- Safari 11+

## Known Limitations
- Components use mock data by default (requires customization for real data)
- Dashboards and reports require appropriate data volume for meaningful insights
- Real-time data updates require page refresh

## Troubleshooting

### Components Not Showing
- Verify Lightning Experience is enabled
- Check page layout permissions
- Ensure GlobalSalesCore package is installed

### Reports Showing No Data
- Verify opportunities have SalesRegion__c field populated
- Check report filters and date ranges
- Ensure user has access to opportunity records

### Components Not Loading
- Check browser console for JavaScript errors
- Verify API version compatibility
- Clear browser cache and retry

## Support
For issues or questions about this package, please refer to the main repository documentation or create an issue in the repository.

## Version History
- **v1.0.0**: Initial release with Regional Dashboard, Opportunity Heatmap, reports, and app page

## License
This package is provided as an educational resource for the Salesforce community.
