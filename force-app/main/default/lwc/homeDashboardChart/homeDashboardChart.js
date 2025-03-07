import { LightningElement, api } from 'lwc';

export default class HomeDashboardChart extends LightningElement {
    @api open = 0;   // Open cases count
    @api closed = 0; // Closed cases count

    get openCasesCount() {
        return this.open;
    }

    get closedCasesCount() {
        return this.closed;
    }


    // Compute the percentage of Open cases
    get percentage() {
        let total = this.open + this.closed;
        return total === 0 ? 0 : Math.round((this.open / total) * 100);
    }
    get closedPercentage() {
        let total = this.open + this.closed;
        return total === 0 ? 0 : Math.round((this.closed / total) * 100);
    }


    // Compute the stroke-dasharray for SVG Pie Chart
    get chartSlice() {
        let total = this.open + this.closed;
        if (total === 0) {
            return "0 100"; // No data case
        }
        let openPercentage = (this.open / total) * 100;
        let closedPercentage = 100 - openPercentage; // Remaining space
        return `${closedPercentage} ${openPercentage}`;  // Two segments
    }
}