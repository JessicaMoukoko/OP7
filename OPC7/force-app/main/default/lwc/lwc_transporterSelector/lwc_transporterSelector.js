import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getTransporterByCountry from '@salesforce/apex/TransporterSelector.getTransporterByCountry';
import createSelectedLivraisonFromOrderId from '@salesforce/apex/LivraisonController.createSelectedLivraisonFromOrderId';
import createCheapestLivraisonFromOrderId from '@salesforce/apex/LivraisonController.createCheapestLivraisonFromOrderId';
import createFastestLivraisonFromOrderId from '@salesforce/apex/LivraisonController.createFastestLivraisonFromOrderId';
const FIELDS = ['Order.BillingCountry', 'Order.Account.AccountType__c'];
export default class Lwc_transporterSelector extends LightningElement {
 
    @api recordId;
    @api currentCountry;
    selectedOption;
    displayAutresTransporters = false;
    selectedTransporter;
    billingCountry;       // Will store the country

    // Wire the Order record
   @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
wiredOrder({ error, data }) {
    if (data && data.fields && data.fields.BillingCountry) {
        this.billingCountry = data.fields.BillingCountry.value?.trim();
         this.accountType = data.fields.Account.value.fields.AccountType__c.value;

        console.log('Billing Country:', this.billingCountry);
         console.log('Account Type:', this.accountType);
    } else if (error) {
        console.error('Error retrieving Order:', error);
    }
}
   comboBoxOptions = [];

    options = [
        { label: 'Le moins cher', value: 'le moins cher' },
        { label: 'Le plus rapide', value: 'le plus rapide' },
        { label: 'Autres transporteurs', value: 'autres' }
    ];

   loadTransporters() {
    if (!this.billingCountry || !this.accountType) {
        console.warn('Missing country or account type');
        return;
    }

    getTransporterByCountry({ 
        pays: this.billingCountry,
        accountType: this.accountType
    })
    .then(result => {
        console.log('Filtered transporters:', result);

        this.comboBoxOptions = result.map(item => ({
            label: item.Name,
            value: item.Id
        }));
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

    handleChangeOptions(event) {
    this.selectedOption = event.detail.value;
    this.displayAutresTransporters = false; 

    if (!this.recordId) {
        console.error('recordId is undefined!');
        return;
    }

    if (this.selectedOption === 'autres') {
    this.displayAutresTransporters = true;

    if (this.billingCountry) {
        this.loadTransporters();
        } 
    }
     else if (this.selectedOption === 'le moins cher') {
        console.log('User selected "le moins cher" option');

        createCheapestLivraisonFromOrderId({ orderId: this.recordId })
            .then(result => {
                console.log('Cheapest livraison:', result);
            })
            .catch(error => {
                console.error('ERROR (cheapest):', JSON.stringify(error));
            });

    } else if (this.selectedOption === 'le plus rapide') {
        console.log('User selected "le plus rapide" option');

        createFastestLivraisonFromOrderId({ orderId: this.recordId })
            .then(result => {
                console.log('Fastest livraison:', result);
            })
            .catch(error => {
                console.error('ERROR (fastest):', JSON.stringify(error));
            });
    }
}


handleTransporterChange(event) {
    this.selectedTransporter = event.detail.value;

    console.log('Selected transporter Id:', this.selectedTransporter);

    if (!this.recordId) {
        console.error('recordId is undefined!');
        return;
    }

    if (!this.selectedTransporter) {
        console.warn('No transporter selected');
        return;
    }

    createSelectedLivraisonFromOrderId({ 
        orderId: this.recordId,
        transporterId: this.selectedTransporter
    })
    .then(result => {
        console.log('Selected livraison created:', result);
    })
    .catch(error => {
        console.error('ERROR (autres):', JSON.stringify(error));
    });
}
}