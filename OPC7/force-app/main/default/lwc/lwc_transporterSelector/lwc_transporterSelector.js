import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import IsResponsableCommercialUser from '@salesforce/apex/ProfileController.IsResponsableCommercialUser';
import getTransporterByCountry from '@salesforce/apex/TransporterSelector.getTransporterByCountry';
import createSelectedLivraisonFromOrderId from '@salesforce/apex/LivraisonController.createSelectedLivraisonFromOrderId';
import createCheapestLivraisonFromOrderId from '@salesforce/apex/LivraisonController.createCheapestLivraisonFromOrderId';
import createFastestLivraisonFromOrderId from '@salesforce/apex/LivraisonController.createFastestLivraisonFromOrderId';
import USER_ID from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const FIELDS = ['Order.BillingCountry', 'Order.Account.AccountType__c'];
export default class Lwc_transporterSelector extends LightningElement {
 
    @api recordId;
    @api currentCountry;
    selectedOption;
    displayAutresTransporters = false;
    selectedTransporter;
    billingCountry; 
    isResponsableCommercial = false;     

    //Méthode pour vérifier si l'utilisateur connecté a le profil de Responsable Commercial
    @wire(IsResponsableCommercialUser, { userId: USER_ID })
    wiredProfileResults({ data, error }) {
    if (data) {
        this.isResponsableCommercial = data === true;
    } else if (error) {
        console.error('Erreur récupération permission:', error);
        this.isResponsableCommercial = false;
    }
}
    //Méthode pour récupérer le pays de facturation et le type de compte de la commande
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


    //Méthode pour charger les transporteurs en fonction du pays de facturation et du type de compte
   loadTransporters() {
    if (!this.billingCountry || !this.accountType) {
        console.warn('Missing country or account type');
        return;
    }
    //methode Apex pour récupérer les transporteurs filtrés par pays de facturation et type de compte
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
    //méthode pour gérer le changement d'option sélectionnée dans le combo box
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

    //méthode Apex pour créer une livraison avec le transporteur le moins cher
    createCheapestLivraisonFromOrderId({ orderId: this.recordId })
        .then(result => {
            console.log('Cheapest livraison:', result);

            // Succes toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: 'Livraison la moins chère créée avec succès.',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            console.error('ERROR (cheapest):', JSON.stringify(error));

            // Erreur toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: 'Une erreur est survenue lors de la création.',
                    variant: 'error'
                })
            );
        });
}

    else if (this.selectedOption === 'le plus rapide') {
    console.log('User selected "le plus rapide" option');

    //Méthode Apex pour créer une livraison avec le transporteur le plus rapide
    createFastestLivraisonFromOrderId({ orderId: this.recordId })
        .then(result => {
            console.log('Fastest livraison:', result);

            // Succes toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: 'Livraison la plus rapide créée avec succès.',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            console.error('ERROR (fastest):', JSON.stringify(error));

            // Erreur toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: 'Une erreur est survenue lors de la création.',
                    variant: 'error'
                })
            );
        });
}
    }

    //Méthode pour gérer le changement de transporteur sélectionné dans le combo box des autres transporteurs
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

        // Méthode Apex pour créer une livraison avec le transporteur sélectionné
    createSelectedLivraisonFromOrderId({ 
        orderId: this.recordId,
        transporterId: this.selectedTransporter
    })
    .then(result => {
        console.log('Selected livraison created:', result);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Succès',
                message: 'Livraison créée avec le transporteur sélectionné.',
                variant: 'success'
            })
        );
    })
    .catch(error => {
        console.error('ERROR (autres):', JSON.stringify(error));

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erreur',
                message: error?.body?.message || 'Une erreur est survenue lors de la création.',
                variant: 'error'
            })
        );
    });
}
}