public with sharing class LivraisonController {

    // Méthode pour créer une livraison avec le transporteur le moins cher pour une commande donnée
      @AuraEnabled
        public static void createLivraisonWithCheapestTransporter(Order order) {
            Transporteur__c cheapestTransporter = TransporterSelector.calculateCheapestTransporter(order);
            
            if (cheapestTransporter != null) {
                Livraison__c newLivraison = new Livraison__c();
                newLivraison.Order__c = order.Id;
                newLivraison.Transporteur__c = cheapestTransporter.Id;
                newLivraison.Account__c = order.AccountId;
                newLiveraison.Status__c = 'En cours';

                insert newLivraison;
            }

        }
        // Méthode pour créer une livraison avec le transporteur le plus rapide pour une commande donnée
        @AuraEnabled
        public static void createLivraisonWithFastestTransporter(Order order) {
            Transporteur__c fastestTransporter = TransporterSelector.calculateFastestTransporter(order);
            
            if (fastestTransporter != null) {
                Livraison__c newLivraison = new Livraison__c();
                newLivraison.Order__c = order.Id;
                newLivraison.Transporteur__c = fastestTransporter.Id;
                newLivraison.Account__c = order.AccountId;                
                newLiveraison.Status__c = 'En cours';

                insert newLivraison;
            }
        }
    // Méthode pour créer une livraison avec un transporteur sélectionné par l'utilisateur pour une commande donnée
        @AuraEnabled
        public static Boolean createLivraisonWithSelectedTransporter(String orderId, String selectedTransporterId) {
          return false;
        }
    
}