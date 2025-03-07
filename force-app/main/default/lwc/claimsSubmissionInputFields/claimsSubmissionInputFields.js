import { api, wire, track, LightningElement } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createClaim from '@salesforce/apex/ClaimsSubmissionInputFieldsController.createClaim';
import associateFilesWithClaimApex from '@salesforce/apex/ClaimsSubmissionInputFieldsController.associateFilesWithClaimApex';
import displayHelpText from '@salesforce/messageChannel/ClaimsSubmissionsMessageChannel1__c';
import focusHelpText from '@salesforce/messageChannel/ClaimsSubmissionsMessageChannel2__c';
import blurHelpText from '@salesforce/messageChannel/ClaimsSubmissionsMessageChannel3__c';


export default class ClaimsSubmissionInputFields extends LightningElement {
    @api
    claimType = 'Claim Type';
    claimReasonInput;
    displayValue = 0;
    displayDisabilityCompSpecific;
    displayPensionSpecific;
    displayHealthcareBenefitSpecific;
    displayEdAndTrainingSpecific;
    displayHousingAssistSpecific;
    displayIncomeAndCredit;

    cType;
    clReason;
    disabDate;
    olderThan65;
    disabDescription;
    incCred;
    healthStat;
    edType;
    edInstitution;
    houseStat;

    @track fieldsList = [];
    @track filesToUpload = [];

    @wire(MessageContext)
    messageContext;

    get claimTypeList() {
        return [
            { label: 'Disability Compensation', value: 'disabilityCompensation' },
            { label: 'Pension', value: 'pension' },
            { label: 'Healthcare Benefits', value: 'healthcareBenefits' },
            { label: 'Education & Training', value: 'educationAndTraining' },
            { label: 'Housing Assistance', value: 'housingAssistance' }
        ];
    }

    get acceptedFormats() {
        return ['.pdf','.doc','.docx','.png','.jpeg','.xls','.xlsx'];
    }

    handleUploadDone(event) {
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach(file => {
            console.log(file.documentId);
            this.filesToUpload.push(file.documentId);
        });
    }

    //event handler to display or not display certain fields for submission depending on the claim type, and to display none if no claim type is selected
    handleChange(event) {

        this.displayDisabilityCompSpecific = false;
        this.displayPensionSpecific = false;
        this.displayHealthcareBenefitSpecific = false;
        this.displayEdAndTrainingSpecific = false;
        this.displayHousingAssistSpecific = false;
        this.displayIncomeAndCredit = false

        if (this.claimType) {
            this.displayValue = true;
        }
        switch (event.detail.value) {
            case 'disabilityCompensation':
                this.displayDisabilityCompSpecific = true;
                break;
            case 'pension':
                this.displayPensionSpecific = true;
                this.displayIncomeAndCredit = true;
                break;
            case 'healthcareBenefits':
                this.displayHealthcareBenefitSpecific = true;
                this.displayIncomeAndCredit = true;
                break;
            case 'educationAndTraining':
                this.displayEdAndTrainingSpecific = true;
                break;
            case 'housingAssistance':
                this.displayHousingAssistSpecific = true;
                this.displayIncomeAndCredit = true;
                break;
            default:
                break;
        }

        this.claimType = event.detail.value;

        const message = {
            displayCase: event.detail.value
        };
        publish(this.messageContext, displayHelpText, message);
    }

    handleEmphasizeHelp(event) {
        const messageFocus = {
            emphasis: event.target.name
        };
        publish(this.messageContext, focusHelpText, messageFocus);
    }

    handleRemoveEmphasis(event) {
        const messageBlur = {
            emphasis: event.target.name
        };
        publish(this.messageContext, blurHelpText, messageBlur);
    }

    handleClick(event) {
        this.clReason = this.template.querySelector('[data-id="claimReason"]').value;
        this.cType = '';
        this.disabilityDate = '';
        this.olderThan65 = '';
        this.disabDescription = '';
        this.incCred = '';
        this.healthStat = '';
        this.edInstitution = '';
        this.edType = '';
        this.houseStat = '';

        switch (this.claimType) {
            case 'disabilityCompensation':
                this.cType = 'Disability';
                this.disabDate = this.template.querySelector('[data-id="disabilityDate"]').value;
                break;
            case 'pension':
                this.cType = 'Pension';
                if (this.template.querySelector('[data-id="ageCheck"]').value == true) {
                    this.olderThan65 = 'Veteran is 65+';
                } else {
                    this.olderThan65 = '';
                }
                this.disabDescription = this.template.querySelector('[data-id="disabilityInfo"]').value;
                this.incCred = this.template.querySelector('[data-id="incomeCredit"]').value;
                break;
            case 'healthcareBenefits':
                this.cType = 'Healthcare Benefits';
                this.incCred = this.template.querySelector('[data-id="incomeCredit"]').value;
                this.healthStat = this.template.querySelector('[data-id="healthStatus"]').value;
                break;
            case 'educationAndTraining':
                this.cType = 'Education and Training';
                this.edInstitution = this.template.querySelector('[data-id="educationInstitution"]').value;
                this.edType = this.template.querySelector('[data-id="educationType"]').value;
                break;
            case 'housingAssistance':
                this.cType = 'Housing Assistance';
                this.incCred = this.template.querySelector('[data-id="incomeCredit"]').value;
                this.houseStat = this.template.querySelector('[data-id="housingStatus"]')?.value;
                break;
            default:
                break;
        }

        this.fieldsList.push(this.cType);
        this.fieldsList.push(this.clReason);
        this.fieldsList.push(this.disabDate);
        this.fieldsList.push(this.olderThan65);
        this.fieldsList.push(this.disabDescription);
        this.fieldsList.push(this.incCred);
        this.fieldsList.push(this.healthStat);
        this.fieldsList.push(this.edType);
        this.fieldsList.push(this.edInstitution);
        this.fieldsList.push(this.houseStat);

        createClaim({ relData : this.fieldsList}).then(result => {
            console.log(result.Id);
            const claimId = result.Id;
            this.associateFilesWithClaim(claimId);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Your Claim was submitted. Thank you.',
                variant: 'success'
            }));
            
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Error creating claim, please try again later.',
                variant: 'error'
            }))
        console.error('Error creating Claim:', error);
        });
    }

    associateFilesWithClaim(claimId) {
        if (this.filesToUpload.length === 0) {
            return;
        }
        const contentDocumentLinks = this.filesToUpload.map(fileId => {
            return {
                ContentDocumentId: fileId,
                LinkedEntityId: claimId,
                ShareType: 'V'
            };
        });
        console.log('ERROR HERE');
        associateFilesWithClaimApex({ contentDocumentLinks: contentDocumentLinks }).then(() => {
                console.log('Files successfully associated with claim');
            })
            .catch(error => {
                console.error('Error associating files with claim:', error);
            });
    }
}