import { LightningElement, api, wire  } from 'lwc';  
import getOrderProducts from '@salesforce/apex/OrderController.getOrderProducts';
import IsResponsableCommercialUser from '@salesforce/apex/ProfileController.IsResponsableCommercialUser';
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


             // colonnes pour le profil Responsable Commercial

    columnsResponsableCommercial = [ { label: OrderName, fieldName: 'OrderName__c', type: 'text' },
        { label: UnitPrice, fieldName: 'UnitPrice', type: 'number' },
        { label: totalPrice, fieldName: 'TotalPrice', type: 'number' },
        { label: ProductQuantity, fieldName: 'Quantity', type: 'number'},
    ];

    extrabuttons = [{
        label: Delete,
        type: 'button-icon',
        initialWidth: 90,
        typeAttributes: {
            iconName: 'utility:delete',
            name: 'delete',
            title: 'Supprimer',
            variant: 'border-filled',
            alternativeText: 'Supprimer'
        } },
    { label: ViewProduct,
         type: 'button', 
            initialWidth: 160,
         typeAttributes: { 
            label: viewProductButton,
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
        this.isResponsableCommercialUser = data === true;
    }

   // propriété calculée pour afficher le tableau Responsable Commercial 

 get isResponsableCommercialTable() {
    return this.isResponsableCommercialUser;
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
}