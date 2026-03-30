@isTest
public class TransporterSelectorTest {
    
    @testSetup
    static void setupTestData() {
        // Creation de transporteurs de test
        Transporteur__c transporter1 = TestDataFactory.createTransporter('Transporter 1', 'Particulier;Professionnel', 'T001');
        Transporteur__c transporter2 = TestDataFactory.createTransporter('Transporter 2', 'Particulier', 'T002');
        Transporteur__c transporter3 = TestDataFactory.createTransporter('Transporter 3', 'Professionnel', 'T003');
        
        // Creation de prix de test pour la France
        TestDataFactory.createPrice('France', transporter1.Id, 50.00, 2);
        TestDataFactory.createPrice('France', transporter2.Id, 30.00, 3);
        TestDataFactory.createPrice('France', transporter3.Id, 80.00, 1);
    }
    
    @isTest
    static void testGetTransporterByCountry_Success() {
        // test de la récupération des transporteurs disponibles pour la France et le type de compte Particulier
        Test.startTest();
        List<Transporteur__c> transporters = TransporterSelector.getTransporterByCountry('France','Particulier');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(transporters, 'Transporter list should not be null');
        Assert.isTrue(transporters.size() > 0, 'Should return at least one transporter for France');
    }
    
    @isTest
    static void testGetTransporterByCountry_NoResults() {
        // test de la récupération des transporteurs pour un pays qui n'existe pas dans les données de test
        Test.startTest();
        List<Transporteur__c> transporters = TransporterSelector.getTransporterByCountry('NonExistentCountry','Particulier');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(transporters, 'List should not be null');
        Assert.areEqual(0, transporters.size(), 'Should return empty list for non-existent country');
    }
    
    @isTest
    static void testGetCheapestTransporter_Success() {
        // test de la récupération du transporteur le moins cher pour la France et le type de compte Particulier
        Test.startTest();
        Transporteur__c cheapest = TransporterSelector.GetCheapestTransporter('France', 'Particulier');
        Test.stopTest();
        // Assert
        Assert.isNotNull(cheapest, 'Should return a transporter');
        Assert.areEqual('Transporter 2', cheapest.Name, 'Should return the cheapest transporter');
    }
    
    @isTest
    static void testGetCheapestTransporter_CompatibleType() {
        // test de la récupération du transporteur le moins cher pour la France et le type de compte Professionnel
        Test.startTest();
        Transporteur__c cheapest = TransporterSelector.GetCheapestTransporter('France', 'Professionnel');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(cheapest, 'Should return a transporter for professional account type');
    }
    
    @isTest
    static void testGetCheapestTransporter_NoCompatibleTransporter() {
        // test de la récupération du transporteur le moins cher pour un pays qui n'existe pas dans les données de test
        Test.startTest();
        Transporteur__c cheapest = TransporterSelector.GetCheapestTransporter('NonExistentCountry', 'Particulier');
        Test.stopTest();
        
        // Assert
        Assert.isNull(cheapest, 'Should return null when no compatible transporter exists');
    }
    
    @isTest
    static void testGetFastestTransporter_Success() {
        // test de la récupération du transporteur le plus rapide pour la France et le type de compte Professionnel
        Test.startTest();
        Transporteur__c fastest = TransporterSelector.GetFastestTransporter('France', 'Professionnel');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(fastest, 'Should return a transporter');
        Assert.areEqual('Transporter 3', fastest.Name, 'Should return the fastest transporter');
    }
    
    @isTest
    static void testGetFastestTransporter_CompatibleType() {
        // test de la récupération du transporteur le plus rapide pour la France et le type de compte Particulier avec un compte compatible
        Test.startTest();
        Transporteur__c fastest = TransporterSelector.GetFastestTransporter('France', 'Particulier');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(fastest, 'Should return a transporter for Particulier account type');
    }
    
    @isTest
    static void testGetFastestTransporter_NoCompatibleTransporter() {
        // test de la récupération du transporteur le plus rapide pour un pays qui n'existe pas avec transporteur incompatible
        Transporteur__c fastest = TransporterSelector.GetFastestTransporter('NonExistentCountry', 'Particulier');
        
        // Assert
        Assert.isNull(fastest, 'Should return null when no compatible transporter exists');
    }
}
