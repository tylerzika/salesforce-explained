# SalesInsightsUI Package

## Overview
The **SalesInsightsUI** package provides user interface components and reporting capabilities for visualizing international sales performance. While the GlobalSalesCore package demonstrates declarative best practices, this package uses **Lightning Web Components to showcase UI customization that goes beyond standard platform features**.

## Why Lightning Web Components?

### Demonstrating Platform Limitations
This package uses custom LWC development to address specific UI requirements that **cannot be met with out-of-the-box features**:

1. **Interactive Heatmap Visualization**
   - Standard dashboards don't support matrix/heatmap layouts with color intensity
   - Native reports can't dynamically toggle between different metrics (amount vs count vs win rate)
   - Cross-dimensional visualization (region × stage) requires custom rendering

2. **Real-Time Regional Filtering**
   - Standard dashboards require page refresh to change filters
   - LWC enables instant client-side filtering without server round-trips
   - Dynamic data updates and metric recalculation in real-time

3. **Responsive Multi-Metric Cards**
   - Native dashboard components have fixed layouts
   - Custom cards with automatic layout adjustment based on screen size
   - Conditional color-coding and formatting not available in standard components

### Following Best Practices
Even when using custom code, this package follows Salesforce best practices:
- **LWC over Aura**: Uses modern Lightning Web Components framework
- **Mock Data for Demo**: Shows UI patterns without requiring Apex
- **Standard Styling**: Uses Salesforce Lightning Design System (SLDS)
- **Configurable Properties**: Allows admins to customize without code changes
- **Accessibility**: Follows WCAG standards for accessibility

### When Custom UI is Appropriate
Use custom LWC components when:
- Standard dashboard components don't support required visualization
- Interactive, real-time filtering is essential
- Complex layouts or conditional formatting exceed platform capabilities
- Specific user experience requires custom interaction patterns

For most reporting needs, **use standard Salesforce Reports and Dashboards** (included in this package).

## Features

### Lightning Web Components

#### Regional Dashboard (regionalDashboard)
**Why Custom**: Standard dashboards can't provide real-time filtering with multiple metric cards and conditional color-coding in a single component.

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
**Why Custom**: Standard Salesforce charts don't support heatmap visualization with intensity-based color coding across two dimensions.

A visual heatmap component that shows opportunity distribution across regions and stages:
- **Metric Selection**: Toggle between Amount, Count, or Win Rate views
- **Heat Intensity**: Color-coded cells showing relative performance (light to dark blue)
- **Grid Layout**: Regions (rows) × Opportunity Stages (columns)
- **Interactive Legend**: Visual guide to understand heat intensity levels
- **Responsive Design**: Optimized for desktop and mobile viewing

**Usage**: Can be added to App Pages, Home Pages, or Record Pages via Lightning App Builder

### Pre-Configured Reports
**Preferred Approach**: These reports use standard Salesforce reporting features and should be the first choice for most reporting needs.

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

4. **Create Dashboards Using Standard Features** (Recommended)
   - Create a new dashboard using standard Dashboard Builder
   - Add report components:
     - Regional Opportunity Pipeline
     - Regional Revenue Performance
   - Add filters for dynamic reporting
   - Share dashboard with appropriate users
   - **Note**: Standard dashboards are preferred over custom LWC for most use cases

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

### Connecting to Real Data
The LWC components currently use mock data for demonstration. To connect to real Salesforce data:

1. **Create Apex Classes** (Only when necessary)
   - Create `@AuraEnabled` methods to query Regional Quotas and Opportunities
   - Apply proper sharing rules (`with sharing`)
   - Bulkify all queries
   
2. **Wire Apex to LWC**
   - Import Apex methods in component JavaScript
   - Use `@wire` decorator for reactive data
   - Handle loading and error states

3. **Update Component Logic**
   - Replace `generateMockData()` with real Apex calls
   - Process returned data to match component format
   - Add error handling

**Note**: Only add Apex when declarative features (reports, dashboards) can't meet the requirement.

### Extending Standard Reports
To customize the included reports:
- Use Report Builder to add/remove fields
- Change groupings and filters
- Add calculated fields using formulas
- Change chart types and colors
- Create joined reports for multiple data sources

## Architecture

The package follows Salesforce best practices:
- **Component-based architecture**: Modular LWC components
- **Reactive programming**: Uses @track and @wire decorators
- **Lightning Design System**: Consistent styling and accessibility
- **Responsive design**: Mobile-first approach
- **Performance optimization**: Efficient rendering and data handling
- **Declarative reports first**: Standard reports as primary option

## Dependencies
This package depends on **GlobalSalesCore** package:
- Custom fields: SalesRegion__c, ForecastCategory__c, CalculatedPriority__c
- Custom objects: RegionalQuota__c
- The metadata relationship is defined in sfdx-project.json

## Browser Support
- Google Chrome (recommended)
- Mozilla Firefox
- Microsoft Edge
- Safari 11+

## Known Limitations
- Components use mock data by default (requires Apex customization for real data)
- Standard dashboards should be preferred when they meet requirements
- Real-time data updates require page refresh unless connected to Apex

## Best Practices Reminder

### Use Standard Features First
Before building custom components:
1. Try standard Reports and Dashboards
2. Use standard Chart types
3. Leverage Dashboard Filters
4. Create Report Types if needed
5. Only use custom LWC when standard features can't meet the requirement

### When to Use Custom vs Standard
- **Standard Reports/Dashboards**: 90% of reporting needs
- **Custom LWC**: Only for unique visualizations or interactions not supported by platform

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
- **v1.0.0**: Initial release with LWC components demonstrating platform limitations, plus standard reports

## License
This package is provided as an educational resource for the Salesforce community.
