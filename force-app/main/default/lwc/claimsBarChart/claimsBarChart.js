import { LightningElement, wire, track } from 'lwc';
import getClaimStatusCounts from '@salesforce/apex/ClaimsController.getClaimStatusCounts';

export default class ClaimsBarChart extends LightningElement {
    @track claimData = [];
    
    statusColors = {
        'Received': ' #060670', 
        'Under Review': ' #060670', 
        'Evidence Gathering': ' #060670', 
        'Decision Pending': ' #060670', 
        'Decision Made': ' #060670',
        //'Closed': '#3498db' 
    };

    @wire(getClaimStatusCounts)
    wiredData({ error, data }) {
        if (data) {
            let maxCount = Math.max(...Object.values(data), 1); // Prevent division by zero

            this.claimData = Object.entries(data).map(([status, count], index) => {
                let barHeight = (count / maxCount) * 150 + 10; // Scale height dynamically
                let xPosition = index * 80 + 50; // Spacing between bars
                let yPosition = 200 - barHeight; // Corrected y-position

                // Split the status text into two parts (for multi-line text)
                let statusLines = status.split(' ');

                return {
                    status,
                    count,
                    color: this.statusColors[status] || ' #060670',
                    x: xPosition,
                    y: yPosition,
                    height: barHeight,
                    labelX: xPosition + 25, // Precompute label positions
                    labelY: 220,
                    countY: yPosition - 5, // Position count above bar
                    firstLine: statusLines[0], // First line of the text
                    secondLine: statusLines[1] || '' // Second line, if exists
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
}