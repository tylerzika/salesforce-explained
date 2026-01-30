import { LightningElement, track } from 'lwc';

export default class OpportunityHeatmap extends LightningElement {
    @track heatmapData = [];
    @track isLoading = true;
    @track selectedMetric = 'amount';

    metricOptions = [
        { label: 'Amount', value: 'amount' },
        { label: 'Count', value: 'count' },
        { label: 'Win Rate', value: 'winRate' }
    ];

    connectedCallback() {
        this.loadHeatmapData();
    }

    handleMetricChange(event) {
        this.selectedMetric = event.detail.value;
        this.loadHeatmapData();
    }

    loadHeatmapData() {
        this.isLoading = true;
        
        // Simulated heatmap data - in production, this would call Apex
        setTimeout(() => {
            this.heatmapData = this.generateHeatmapData();
            this.isLoading = false;
        }, 800);
    }

    generateHeatmapData() {
        const regions = ['North America', 'EMEA', 'APAC', 'LATAM'];
        const stages = ['Prospecting', 'Qualification', 'Proposal', 'Negotiation', 'Closed Won'];

        return regions.map(region => ({
            region: region,
            stages: stages.map(stage => {
                const amount = this.randomAmount(50000, 500000);
                const count = Math.floor(Math.random() * 20) + 1;
                const winRate = Math.floor(Math.random() * 60) + 20;

                return {
                    stage: stage,
                    amount: amount,
                    count: count,
                    winRate: winRate,
                    value: this.getMetricValue(amount, count, winRate),
                    intensity: this.calculateIntensity(amount, count, winRate)
                };
            })
        }));
    }

    getMetricValue(amount, count, winRate) {
        switch (this.selectedMetric) {
            case 'amount':
                return this.formatCurrency(amount);
            case 'count':
                return count;
            case 'winRate':
                return winRate + '%';
            default:
                return amount;
        }
    }

    calculateIntensity(amount, count, winRate) {
        let value;
        switch (this.selectedMetric) {
            case 'amount':
                value = amount / 500000; // Normalize to max value
                break;
            case 'count':
                value = count / 20;
                break;
            case 'winRate':
                value = winRate / 100;
                break;
            default:
                value = 0.5;
        }

        // Return intensity class based on value
        if (value >= 0.8) return 'intensity-high';
        if (value >= 0.6) return 'intensity-medium-high';
        if (value >= 0.4) return 'intensity-medium';
        if (value >= 0.2) return 'intensity-low';
        return 'intensity-very-low';
    }

    randomAmount(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    formatCurrency(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(amount);
    }

    get stages() {
        if (this.heatmapData.length > 0) {
            return this.heatmapData[0].stages.map(s => s.stage);
        }
        return [];
    }
}
