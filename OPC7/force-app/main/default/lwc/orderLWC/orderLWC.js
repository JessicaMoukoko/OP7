import { LightningElement, api, wire  } from 'lwc';  
import getOrderProducts from '@salesforce/apex/OrderController.getOrderProducts';
import IsResponsableCommercialUser from '@salesforce/apex/ProfileController.IsResponsableCommercialUser';
import createCheapestLivraisonFromOrderId from '@salesforce/apex/LivraisonController.createCheapestLivraisonFromOrderId';
import createFastestLivraisonFromOrderId from '@salesforce/apex/LivraisonController.createFastestLivraisonFromOrderId';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';

export default class OrderLWC extends  LightningElement  {

 // Récupération de l'ID utilisateur courant
 
userId; 
connectedCallback() {
    this.userId = USER_ID;
}

@api recordId;
IsResponsableCommercialUser = false;
OrderProducts;
error;
wiredOrderProductsResults;
wiredProfileResults;
clickedButtonLabelMoinsCher = "Créer une livraison avec le transporteur le moins cher";
clickedButtonLabelPlusRapide = "Créer une livraison avec le transporteur le plus rapide";

             // colonnes pour le profil Responsable Commercial

    columnsResponsableCommercial = [
        { label: 'Nom du Produit', fieldName: 'Product2.Name', type: 'text' },
        { label: 'Prix Unitaire', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'Quantité', fieldName: 'Quantity', type: 'number'},
        { label: 'Prix Total', fieldName: 'TotalPrice', type: 'currency' }
    ];

    extrabuttons = [{
        label: 'Delete',
        type: 'button-icon',
        initialWidth: 90,
        typeAttributes: {
            iconName: 'utility:delete',
            name: 'delete',
            title: 'Supprimer',
            variant: 'border-filled',
            alternativeText: 'Supprimer'
        } },
    { label: 'ViewProduct',
         type: 'button', 
            initialWidth: 160,
         typeAttributes: { 
            label: 'View Product',
            iconName: 'utility:preview',
             name: 'preview',
              title: 'Voir Produit',
                variant: 'brand',
            alternativeText: 'Voir Produit'
         } }
    ]
    
           // Récupération des produits liés à la commande

   @wire(getOrderProducts, { OrderId: '$recordId' })
wiredOpportunities(result) {
    
    // on stocke le résultat du wire pour le rafraîchir plus tard
    this.wiredOrderProductsResults = result;

    if (result.data) {

        this.OrderProducts = result.data;
        this.error = undefined;

    } else if (result.error) {
        this.error = result.error;
        this.OrderProducts = undefined;
    }
}

      // Vérification du profil utilisateur grace à la méthode Apex

@wire(IsResponsableCommercialUser, { userId: '$userId' })
    wiredProfileResults({ data }) {
        this.IsResponsableCommercialUser = data === true;
    }

   // propriété calculée pour afficher le tableau Responsable Commercial 

 get isResponsableCommercialTable() {
    return this.IsResponsableCommercialUser;
}

   // gestion des actions sur les lignes du tableau

 handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === 'delete') {
        this.handleDelete(row.Id);
    } 
    else if (actionName === 'preview') {
        this.navigateToProduct(row.IdDuProduit__c);
    }
}

    handleClickMoinsCher(event) {
        this.clickedButtonLabel = event.target.label;
        createCheapestLivraisonFromOrderId({ orderId: this.recordId })
            .then(() => {
                refreshApex(this.wiredOrderProductsResults);
            })
            .catch(error => {
                console.error('Erreur création livraison :', error);
            });
    }

    handleClickPlusRapide(event) {
        this.clickedButtonLabel = event.target.label;
        createFastestLivraisonFromOrderId({ orderId: this.recordId })
            .then(() => {
                refreshApex(this.wiredOrderProductsResults);
            })
            .catch(error => {
                console.error('Erreur création livraison :', error);
            });
    }

}