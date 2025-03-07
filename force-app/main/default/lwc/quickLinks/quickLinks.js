import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class QuickLinks extends NavigationMixin(LightningElement) {
    // Define an array of links that will be displayed as buttons or clickable items
    links = [
        { label: 'Home', url: 'home' },
        { label: 'Personal Info', url: 'Veteran_Personal_Data__c' },
        { label: 'Claims/Appeals Data', url: 'Claims_Data_Page__c' },
        { label: 'Submit a Claim', url: 'Claim_Submission_Page__c' },
        { label: 'Submit an Appeal', url: 'Appeals_Submission_Page__c' }
    ];

    // Method to handle navigation when a user clicks on a link
    navigate(event) {
        const pageName = event.target.dataset.url;
        console.log('Navigating to:', pageName);

        let pageRef;

        // If the link is "Home", navigate to the external URL for the home page
        if (pageName === 'home') {
            pageRef = {
                type: 'standard__webPage',
                attributes: {
                    url: 'https://awcomputing502.my.site.com/vtup/s/'
                }
            };
        } else { // Otherwise, navigate to a community page using the named page URL
            pageRef = {
                type: 'comm__namedPage',
                attributes: {
                    name: pageName
                }
            };
        }
        // Try to navigate to the target page using the NavigationMixin's Navigate method
        try {
            this[NavigationMixin.Navigate](pageRef);
        } catch (error) {
            console.error('Navigation error:', error);
        }
    }
}