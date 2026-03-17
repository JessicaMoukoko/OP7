public with sharing class LivraisonController {

    // Méthode pour créer une livraison avec le transporteur le moins cher pour une commande donnée
      @AuraEnabled
        public static void createLivraisonWithCheapestTransporter(Order order, prix__c prix) {
            Transporteur__c cheapestTransporter = TransporterSelector.GetCheapestTransporter(order.Pays__c);
            
            if (cheapestTransporter != null) {
                Livraison__c cheapestLivraison = new Livraison__c();
                cheapestLivraison.Order__c = order.Id;
                cheapestLivraison.Transporteur__c = cheapestTransporter.Id;
                cheapestLivraison.prix__c = prix.Id;
                cheapestLivraison.Account__c = order.AccountId;
                cheapestLivraison.Status__c = 'En cours';
            }
                insert cheapestLivraison;
            
        }
        
        // Méthode pour créer une livraison avec le transporteur le plus rapide pour une commande donnée
        @AuraEnabled

        public static void createLivraisonWithFastestTransporter(Order order, Prix__c prix) {
            Transporteur__c fastestTransporter = TransporterSelector.GetFastestTransporter(order.Pays__c);
            
            if (fastestTransporter != null) {
                Livraison__c fastestLivraison = new Livraison__c();
                fastestLivraison.Order__c = order.Id;
                fastestLivraison.Transporteur__c = fastestTransporter.Id;
                fastestLivraison.prix__c = prix.Id;
                fastestLivraison.Account__c = order.AccountId;                
                fastestLivraison.Status__c = 'En cours';

                insert fastestLivraison;
            }
        }
    // Méthode pour créer une livraison avec un transporteur sélectionné par l'utilisateur pour une commande donnée
        @AuraEnabled
        public static void createLivraisonWithSelectedTransporter(Order order, Prix__c prix) {

        Transporteur__c SelectedTransporter = TransporterSelector.getTransporterByCountry(order.Pays__c);
            
            if (SelectedTransporter != null) {
                Livraison__c selectedLivraison = new Livraison__c();
                selectedLivraison.Order__c = order.Id;
                selectedLivraison.Transporteur__c = SelectedTransporter.Id;
                selectedLivraison.prix__c = prix.Id;
                selectedLivraison.Account__c = order.AccountId;                
                selectedLivraison.Status__c = 'En cours';

                insert selectedLivraison;
            }
        
        }
    
}