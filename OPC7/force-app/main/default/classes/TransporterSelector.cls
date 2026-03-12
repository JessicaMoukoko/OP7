public with sharing class TransporterSelector {

/*
3/ Faire une méthode capable d'afficher les transporteurs disponibles pour un pays et une commande donnée (= compromis)
 */

private static final Map<String, Set<String>> TRANSPORTER_CLIENT_TYPES = new Map<String, Set<String>>{
    '1' => new Set<String>{'Particulier', 'Professionnel'},    // Chronopost
    '2' => new Set<String>{'Professionnel'},                    // DHL Express
    '3' => new Set<String>{'Particulier'},                      // La Poste
    '4' => new Set<String>{'Particulier', 'Professionnel'},    // UPS
    '5' => new Set<String>{'Professionnel'},                    // FedEx
    '6' => new Set<String>{'Particulier'},                      // GLS
    '7' => new Set<String>{'Particulier'},                      // Mondial Relay
    '8' => new Set<String>{'Professionnel'},                    // TNT
    '9' => new Set<String>{'Particulier'},                      // Colis Prive
    '10' => new Set<String>{'Professionnel'},                   // DB Schenker
    '11' => new Set<String>{'Particulier', 'Professionnel'},   // Geodis
    '12' => new Set<String>{'Particulier'},                     // Amazon Logistics
    '13' => new Set<String>{'Particulier', 'Professionnel'},   // DPD
    '14' => new Set<String>{'Professionnel'},                   // XPO Logistics
    '15' => new Set<String>{'Particulier'}                      // Hermes
};

private static Boolean isTransporterAvailableForClientType(String transporterId, String clientType) {
    return TRANSPORTER_CLIENT_TYPES.containsKey(transporterId) && 
           TRANSPORTER_CLIENT_TYPES.get(transporterId).contains(clientType);
}

public static Transporteur__c calculateCheapestTransporter(Order order) {
    Account account = AccountSelector.getAccountById(order.AccountId);

    try {
        
        // Requête pour trouver les transporteurs avec le tarif minimum pour le pays
        List<Prix__c> prices = [
            SELECT Id, transporteur__c, tarif__c, transporteur__r.Name
            FROM Prix__c
            WHERE pays__c = :order.ShippingCountry
            ORDER BY tarif__c ASC
        ];


        // Boucle pour trouver le premier transporteur compatible avec le type de client
        Transporteur__c cheapestTransporter = null;
        for (Prix__c price : prices) {
            if (isTransporterAvailableForClientType(price.transporteur__c, account.AccountType__c)) {
                // Récupérer les détails du transporteur
                cheapestTransporter = [
                    SELECT Id, Name, Délai_de_livraison__c
                    FROM Transporteur__c
                    WHERE Id = :price.transporteur__c
                    LIMIT 1
                ];
                
            }
        }

        return cheapestTransporter;

    } catch (Exception e) {
        System.debug('Erreur lors du calcul du transporteur le moins cher: ' + e.getMessage());
        return null;
    }
}


public static Transporteur__c calculateFastestTransporter(Order order) {
    Account account = AccountSelector.getAccountById(order.AccountId);

    try {
        // Vérifier que la commande, le compte et le pays de livraison existent
       
        // Requête pour trouver les transporteurs avec le délai de livraison minimum pour le pays
        List<Prix__c> prices = [
            SELECT Id, transporteur__c, transporteur__r.Name, transporteur__r.Délai_de_livraison__c
            FROM Prix__c
            WHERE pays__c = :order.ShippingCountry
            ORDER BY transporteur__r.Délai_de_livraison__c ASC
        ];


        // Boucle pour trouver le premier transporteur compatible avec le type de client
        Transporteur__c fastestTransporter = null;
        for (Prix__c price : prices) {
            if (isTransporterAvailableForClientType(price.transporteur__c, account.AccountType__c)) {
                // Récupérer les détails du transporteur
                fastestTransporter = [
                    SELECT Id, Name, Délai_de_livraison__c
                    FROM Transporteur__c
                    WHERE Id = :price.transporteur__c
                    LIMIT 1
                ];
            }
        }       

        return fastestTransporter;

    } catch (Exception e) {
        System.debug('Erreur lors du calcul du transporteur le plus rapide: ' + e.getMessage());
        return null;
    }
}
}