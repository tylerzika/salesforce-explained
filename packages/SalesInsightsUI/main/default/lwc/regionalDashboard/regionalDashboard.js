import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

export default class RegionalDashboard extends LightningElement {
    @track selectedRegion = 'All Regions';
    @track dashboardData = [];
    @track isLoading = true;

    userId = USER_ID;

    regionOptions = [
        { label: 'All Regions', value: 'All Regions' },
        { label: 'North America', value: 'North America' },
        { label: 'EMEA', value: 'EMEA' },
        { label: 'APAC', value: 'APAC' },
        { label: 'LATAM', value: 'LATAM' }
    ];

    connectedCallback() {
        this.loadDashboardData();
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
        this.loadDashboardData();
    }

    loadDashboardData() {
        this.isLoading = true;
        
        // Simulated dashboard data - in production, this would call Apex
        setTimeout(() => {
            this.dashboardData = this.generateMockData();
            this.isLoading = false;
        }, 1000);
    }

    generateMockData() {
        const regions = this.selectedRegion === 'All Regions' 
            ? ['North America', 'EMEA', 'APAC', 'LATAM']
            : [this.selectedRegion];

        return regions.map(region => ({
            id: region,
            region: region,
            quota: this.randomAmount(500000, 2000000),
            actual: this.randomAmount(300000, 1800000),
            openOpportunities: Math.floor(Math.random() * 50) + 10,
            closedWon: Math.floor(Math.random() * 30) + 5,
            pipelineValue: this.randomAmount(1000000, 5000000)
        }));
    }

    randomAmount(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    get formattedData() {
        return this.dashboardData.map(data => ({
            ...data,
            quotaFormatted: this.formatCurrency(data.quota),
            actualFormatted: this.formatCurrency(data.actual),
            pipelineFormatted: this.formatCurrency(data.pipelineValue),
            attainment: Math.round((data.actual / data.quota) * 100) + '%',
            attainmentClass: this.getAttainmentClass(data.actual, data.quota)
        }));
    }

    formatCurrency(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(amount);
    }

    getAttainmentClass(actual, quota) {
        const percentage = (actual / quota) * 100;
        if (percentage >= 90) return 'slds-text-color_success';
        if (percentage >= 70) return 'slds-text-color_default';
        return 'slds-text-color_error';
    }
}
