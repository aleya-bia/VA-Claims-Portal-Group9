import { LightningElement, api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService'
import displayHelpText from '@salesforce/messageChannel/ClaimsSubmissionsMessageChannel1__c';
import focusHelpText from '@salesforce/messageChannel/ClaimsSubmissionsMessageChannel2__c';
import blurHelpText from '@salesforce/messageChannel/ClaimsSubmissionsMessageChannel3__c';


export default class ClaimsSubmissionAssistancePanel extends LightningElement {
    @api
    helpText='';

    claimReasonText = '<p>Describe the conditions that led you want to file a claim with the VA. Make sure this claim is not something that needs to be handled by an outside service, and that there is some condition tying this claim to the services the VA provides for.<br>Be detailed! Our representatives want to give you the best possible chance at your claim being accepted, so giving them all the information they need is essential.</p><br><br>'
    disabilityCompDateText = '<p>The VA needs to know when your disability began or worsened so they can provide resources to you according to your situation. Please only input the date the disability began if that disability prevented you from earning an income in any way. Otherwise, denote when that disability worsened to the point of preventing you from working.</p><br><br>';
    disabledOr65PlusText = '<p>In order to file for Pension, you must either be 65 or older or be permanently disabled. If you are over 65, please check the checkbox. Otherwise, fill out the Disability description box to the best of your ability.</p><br><br>';
    incomeCreditText = '<p>Input your average annual income in USD, and your credit score. This should be formatted like the following:<br><i>$40000; 550</i><br>The VA will base the claim value on your income and credit score. We also use this information to ensure the validity of your claim. If you dont know your credit score, you can check it at this link.</p><br><br>';
    healthStatusText = '<p>Describe your health to the best of your ability. Include any conditions you have been dealing with that are not labeled as a disability, such as acid reflux or arthritis. Include any medications you currently take, or are perscribed. Include any recent (within the last year) visits to the Doctor\'s office. Include any visits to the ER within the last 10 years. Any other medical information you feel is relevant should go in this box.</p><br><br>';
    educationTypeText ='<p>Please give a brief description of the education type you are requesting assistance with. The best way to fill this field is with the name of the course and a short description of what things you might be learning throughout.</p><br><br>';
    educationInstitutionText = '<p>The name of your institution is requested so that the VA can be sure that the education you are receiving is from a good source. We reccommend you do research on the institution you wish to be educated from before filing a claim to be sure they meet our standards.</p><br><br>';
    housingStatusText = '<p>We need to know your housing status at the moment to understand what kind of assistance you might need. Please be descriptive in your response.</p>';

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        const sub1 = subscribe(
            this.messageContext,
            displayHelpText,
            (message) => this.handleDisplayMessage(message)
        );

        const sub2 = subscribe(
            this.messageContext,
            focusHelpText,
            (messageFocus) => this.handleFocusMessage(messageFocus)
        );
        
        const sub3 = subscribe(
            this.messageContext,
            blurHelpText,
            (messageBlur) => this.handleBlurMessage(messageBlur)
        );

    }

    handleDisplayMessage(message) {
        this.helpText = this.claimReasonText;
        switch(message.displayCase) {
            case 'disabilityCompensation':
                this.helpText += this.disabilityCompDateText;
                break;
            case 'pension':
                this.helpText += this.disabledOr65PlusText + this.incomeCreditText;
                break;
            case 'healthcareBenefits':
                this.helpText += this.incomeCreditText + this.healthStatusText;
                break;
            case 'educationAndTraining':
                this.helpText += this.educationTypeText + this.educationInstitutionText;
                break;
            case 'housingAssistance':
                this.helpText += this.incomeCreditText + this.housingStatusText;
                break;
            default:
                break;
        }
    }



    handleFocusMessage(messageFocus) {
        switch(messageFocus.emphasis) {
            default:
                this.disabilityCompDateText = '<em>' + this.disabilityCompDateText + '</em>';
                break;
        }
    }

    handleBlurMessage(messageBlur) {
        switch(messageBlur.emphasis) {
            default:
                this.disabilityCompDateText = this.disabilityCompDateText.substring(4,this.disabilityCompDateText.length-4);
                break;
        }
    }


}