@isTest
public class TransporterSelectorTest {
    
    @testSetup
    static void setupTestData() {
        // Create test transporters
        Transporteur__c transporter1 = TestDataFactory.createTransporter('Transporter 1', 'Particulier;Professionnel', 'T001');
        Transporteur__c transporter2 = TestDataFactory.createTransporter('Transporter 2', 'Particulier', 'T002');
        Transporteur__c transporter3 = TestDataFactory.createTransporter('Transporter 3', 'Professionnel', 'T003');
        
        // Create test prices for France
        TestDataFactory.createPrice('France', transporter1.Id, 50.00, 2);
        TestDataFactory.createPrice('France', transporter2.Id, 30.00, 3);
        TestDataFactory.createPrice('France', transporter3.Id, 80.00, 1);
    }
    
    @isTest
    static void testGetTransporterByCountry_Success() {
        // Act
        Test.startTest();
        List<Transporteur__c> transporters = TransporterSelector.getTransporterByCountry('France','Particulier');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(transporters, 'Transporter list should not be null');
        Assert.isTrue(transporters.size() > 0, 'Should return at least one transporter for France');
    }
    
    @isTest
    static void testGetTransporterByCountry_NoResults() {
        // Act
        List<Transporteur__c> transporters = TransporterSelector.getTransporterByCountry('NonExistentCountry','Particulier');
        
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
        Assert.isNotNull(fastest, 'Should return a transporter for Particulier account type');
    }
    
    @isTest
    static void testGetFastestTransporter_NoCompatibleTransporter() {
        // Act
        Transporteur__c fastest = TransporterSelector.GetFastestTransporter('NonExistentCountry', 'Particulier');
        
        // Assert
        Assert.isNull(fastest, 'Should return null when no compatible transporter exists');
    }
}
