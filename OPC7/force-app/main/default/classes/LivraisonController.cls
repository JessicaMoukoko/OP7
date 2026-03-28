public with sharing class LivraisonController {

    // Méthode pour créer une livraison avec le transporteur le moins cher pour une commande donnée
      @AuraEnabled
        public static void createLivraisonWithCheapestTransporter(Order order, Prix__c prix) {
            Transporteur__c cheapestTransporter = TransporterSelector.GetCheapestTransporter(prix.Pays__c, order.Account.AccountType__c);
            
            if (cheapestTransporter != null) {
                Livraison__c cheapestLivraison = new Livraison__c();
                cheapestLivraison.Order__c = order.Id;
                cheapestLivraison.Transporteur__c = cheapestTransporter.Id;
                cheapestLivraison.prix__c = prix.Id;
                cheapestLivraison.Account__c = order.AccountId;
                cheapestLivraison.Statut__c = 'En cours';
                insert cheapestLivraison;
            } 
        }
        
        // Méthode pour créer une livraison avec le transporteur le plus rapide pour une commande donnée
        @AuraEnabled
        public static void createLivraisonWithFastestTransporter(Order order, Prix__c prix) {
            Transporteur__c fastestTransporter = TransporterSelector.GetFastestTransporter(prix.Pays__c, order.Account.AccountType__c);
            
            if (fastestTransporter != null) {
                Livraison__c fastestLivraison = new Livraison__c();
                fastestLivraison.Order__c = order.Id;
                fastestLivraison.Transporteur__c = fastestTransporter.Id;
                fastestLivraison.prix__c = prix.Id;
                fastestLivraison.Account__c = order.AccountId;                
                fastestLivraison.Statut__c = 'En cours';
                insert fastestLivraison;
            } 
        }

    // Méthode pour créer une livraison avec un transporteur sélectionné par l'utilisateur pour une commande donnée
        @AuraEnabled
        public static void createLivraisonWithSelectedTransporter(Order order, Prix__c prix) {

        List<Transporteur__c> SelectedTransporter = TransporterSelector.getTransporterByCountry(prix.Pays__c, order.Account.AccountType__c);
            
            if (SelectedTransporter != null) {
                Livraison__c selectedLivraison = new Livraison__c();
                selectedLivraison.Order__c = order.Id;
                selectedLivraison.Transporteur__c = SelectedTransporter[0].Id;
                selectedLivraison.prix__c = prix.Id;
                selectedLivraison.Account__c = order.AccountId;                
                selectedLivraison.Statut__c = 'En cours';

                insert selectedLivraison;
            }
        
        }

    // Wrapper methods for LWC - accepting IDs instead of sObjects
    @AuraEnabled
    public static void createCheapestLivraisonFromOrderId(String orderId) {
        try {
            Order order = [SELECT Id, AccountId, BillingAddress, Account.AccountType__c FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED LIMIT 1];
            
            // Get the country from the billing address
            String country = order.BillingAddress.getCountry();
            
            // Get the cheapest Prix for the country with a compatible transporter
            List<Prix__c> prixList = [SELECT Id, Pays__c, Tarif__c FROM Prix__c 
                                     WHERE Pays__c = :country 
                                     AND Transporteur__c IN (
                                         SELECT Id FROM Transporteur__c 
                                         WHERE Type_Client__c INCLUDES (:order.Account.AccountType__c)
                                     )
                                      WITH SECURITY_ENFORCED 
                                     ORDER BY Tarif__c ASC
                                     LIMIT 1];
            
            if (!prixList.isEmpty()) {
                createLivraisonWithCheapestTransporter(order, prixList[0]);
            } else {
                throw new AuraHandledException('Aucun transporteur compatible trouvé pour le pays ' + country + ' et le type de client ' + order.Account.AccountType__c);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erreur lors de la création de la livraison : ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createFastestLivraisonFromOrderId(String orderId) {
        try {
            Order order = [SELECT Id, AccountId, BillingAddress, Account.AccountType__c FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED LIMIT 1];
            
            // Get the country from the billing address
            String country = order.BillingAddress.getCountry();
            
            // Get the fastest Prix for the country with a compatible transporter
            List<Prix__c> prixList = [SELECT Id, Pays__c, Delai_De_Livraison__c FROM Prix__c 
                                     WHERE Pays__c = :country 
                                     AND Transporteur__c IN (
                                         SELECT Id FROM Transporteur__c 
                                         WHERE Type_Client__c INCLUDES (:order.Account.AccountType__c)
                                     )
                                     WITH SECURITY_ENFORCED 
                                     ORDER BY Delai_De_Livraison__c ASC
                                     LIMIT 1];
            
            if (!prixList.isEmpty()) {
                createLivraisonWithFastestTransporter(order, prixList[0]);
            } else {
                throw new AuraHandledException('Aucun transporteur compatible trouvé pour le pays ' + country + ' et le type de client ' + order.Account.AccountType__c);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erreur lors de la création de la livraison : ' + e.getMessage());
        }
    }
    
    @AuraEnabled
public static void createSelectedLivraisonFromOrderId(String orderId, Id transporterId) {
    try {
        if (orderId == null || transporterId == null) {
            throw new AuraHandledException('Missing parameters');
        }

        Order order = [
            SELECT Id, AccountId, BillingAddress, Account.AccountType__c 
            FROM Order 
            WHERE Id = :orderId 
            WITH SECURITY_ENFORCED 
            LIMIT 1
        ];
        
        String country = order.BillingAddress.getCountry();

        List<Prix__c> prixList = [
            SELECT Id, Pays__c, Tarif__c, Transporteur__c
            FROM Prix__c 
            WHERE Pays__c = :country 
            AND Transporteur__c = :transporterId
            AND Transporteur__c IN (
                SELECT Id FROM Transporteur__c 
                WHERE Type_Client__c INCLUDES (:order.Account.AccountType__c)
            )
            WITH SECURITY_ENFORCED 
            LIMIT 1
        ];
        
        if (!prixList.isEmpty()) {
            createLivraisonWithSelectedTransporter(order, prixList[0]);
        } else {
            throw new AuraHandledException(
                'Aucun prix trouvé pour ce transporteur et ce pays.'
            );
        }

    } catch (Exception e) {
        throw new AuraHandledException(
            'Erreur lors de la création de la livraison : ' + e.getMessage()
        );
    }
}

}