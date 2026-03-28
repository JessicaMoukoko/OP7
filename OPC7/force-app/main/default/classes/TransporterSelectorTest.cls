@isTest
public class TransporterSelectorTest {
    
    @testSetup
    static void setupTestData() {
        // Create test transporters
        List<Transporteur__c> transporters = new List<Transporteur__c>();
        transporters.add(new Transporteur__c(
            Name = 'Transporter 1',
            Type_Client__c = 'Particulier;Professionnel',
            Identifiant__c = 'T001'
        ));
        transporters.add(new Transporteur__c(
            Name = 'Transporter 2',
            Type_Client__c = 'Particulier',
            Identifiant__c = 'T002'
        ));
        transporters.add(new Transporteur__c(
            Name = 'Transporter 3',
            Type_Client__c = 'Professionnel',
            Identifiant__c = 'T003'
        ));
        insert transporters;
        
        // Create test prices
        List<Prix__c> prices = new List<Prix__c>();
        prices.add(new Prix__c(
            Pays__c = 'France',
            Transporteur__c = transporters[0].Id,
            Tarif__c = 50.00,
            Delai_De_Livraison__c = 2
        ));
        prices.add(new Prix__c(
            Pays__c = 'France',
            Transporteur__c = transporters[1].Id,
            Tarif__c = 30.00,
            Delai_De_Livraison__c = 3
        ));
        prices.add(new Prix__c(
            Pays__c = 'France',
            Transporteur__c = transporters[2].Id,
            Tarif__c = 80.00,
            Delai_De_Livraison__c = 1
        ));
        prices.add(new Prix__c(
            Pays__c = 'Germany',
            Transporteur__c = transporters[0].Id,
            Tarif__c = 60.00,
            Delai_De_Livraison__c = 5
        ));
        insert prices;
    }
    
    @isTest
    static void testGetTransporterByCountry_Success() {
        // Act
        List<Transporteur__c> transporters = TransporterSelector.getTransporterByCountry('France');
        
        // Assert
        Assert.isNotNull(transporters, 'Transporter list should not be null');
        Assert.isTrue(transporters.size() > 0, 'Should return at least one transporter for France');
    }
    
    @isTest
    static void testGetTransporterByCountry_NoResults() {
        // Act
        List<Transporteur__c> transporters = TransporterSelector.getTransporterByCountry('NonExistentCountry');
        
        // Assert
        Assert.isNotNull(transporters, 'List should not be null');
        Assert.areEqual(0, transporters.size(), 'Should return empty list for non-existent country');
    }
    
    @isTest
    static void testGetCheapestTransporter_Success() {
        // Act
        Transporteur__c cheapest = TransporterSelector.GetCheapestTransporter('France', 'Particulier');
        
        // Assert
        Assert.isNotNull(cheapest, 'Should return a transporter');
        Assert.areEqual('Transporter 2', cheapest.Name, 'Should return the cheapest transporter');
    }
    
    @isTest
    static void testGetCheapestTransporter_CompatibleType() {
        // Act
        Transporteur__c cheapest = TransporterSelector.GetCheapestTransporter('France', 'Professionnel');
        
        // Assert
        Assert.isNotNull(cheapest, 'Should return a transporter for professional account type');
    }
    
    @isTest
    static void testGetCheapestTransporter_NoCompatibleTransporter() {
        // Act
        Transporteur__c cheapest = TransporterSelector.GetCheapestTransporter('NonExistentCountry', 'Particulier');
        
        // Assert
        Assert.isNull(cheapest, 'Should return null when no compatible transporter exists');
    }
    
    @isTest
    static void testGetFastestTransporter_Success() {
        // Act
        Transporteur__c fastest = TransporterSelector.GetFastestTransporter('France', 'Professionnel');
        
        // Assert
        Assert.isNotNull(fastest, 'Should return a transporter');
        Assert.areEqual('Transporter 3', fastest.Name, 'Should return the fastest transporter');
    }
    
    @isTest
    static void testGetFastestTransporter_CompatibleType() {
        // Act
        Transporteur__c fastest = TransporterSelector.GetFastestTransporter('France', 'Particulier');
        
        // Assert
        Assert.isNotNull(fastest, 'Should return a transporter for personal account type');
    }
    
    @isTest
    static void testGetFastestTransporter_NoCompatibleTransporter() {
        // Act
        Transporteur__c fastest = TransporterSelector.GetFastestTransporter('NonExistentCountry', 'Particulier');
        
        // Assert
        Assert.isNull(fastest, 'Should return null when no compatible transporter exists');
    }
    
    @isTest
    static void testGetFastestTransporter_DifferentCountry() {
        // Act
        Transporteur__c fastest = TransporterSelector.GetFastestTransporter('Germany', 'Particulier');
        
        // Assert
        Assert.isNotNull(fastest, 'Should return a transporter for Germany');
        Assert.areEqual('Transporter 1', fastest.Name, 'Should return the only available transporter for Germany');
    }
}
