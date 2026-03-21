public with sharing class TransporterSelector {
   // méthode pour récupérer les transporteurs associés à une commande donnée
    public static List<Transporteur__c> getTransporterByCountry(string  pays) {

     List<Transporteur__c> transporters = [ SELECT Id, Name,Type_Client__c,Identifiant__c FROM Transporteur__c
      WHERE ID in (SELECT Transporteur__c FROM Prix__c WHERE Pays__c =: pays )];
        return transporters;
}

  public static Transporteur__c GetCheapestTransporter(string pays, string accountType) {
    // Find the cheapest price for the country with a transporter that accepts the account type
    List<Prix__c> compatiblePrices = [SELECT Transporteur__c, Tarif__c 
                                       FROM Prix__c 
                                       WHERE Pays__c = :pays 
                                       AND Transporteur__c IN (
                                           SELECT Id FROM Transporteur__c 
                                           WHERE Type_Client__c INCLUDES (:accountType)
                                       )
                                       ORDER BY Tarif__c ASC 
                                       LIMIT 1];
    
    if (compatiblePrices.isEmpty()) {
      return null;
    }
    
    return [SELECT Id, Name, Type_Client__c, Identifiant__c FROM Transporteur__c
            WHERE Id = :compatiblePrices[0].Transporteur__c 
            LIMIT 1];
  }

  public static Transporteur__c GetFastestTransporter(string pays, string accountType) {
    // Find the fastest delivery for the country with a transporter that accepts the account type
    List<Prix__c> compatiblePrices = [SELECT Transporteur__c, Delai_De_Livraison__c 
                                       FROM Prix__c 
                                       WHERE Pays__c = :pays 
                                       AND Transporteur__c IN (
                                           SELECT Id FROM Transporteur__c 
                                           WHERE Type_Client__c INCLUDES (:accountType)
                                       )
                                       ORDER BY Delai_De_Livraison__c ASC 
                                       LIMIT 1];
    
    if (compatiblePrices.isEmpty()) {
      return null;
    }
    
    return [SELECT Id, Name, Type_Client__c, Identifiant__c FROM Transporteur__c
            WHERE Id = :compatiblePrices[0].Transporteur__c 
            LIMIT 1];
  }
}