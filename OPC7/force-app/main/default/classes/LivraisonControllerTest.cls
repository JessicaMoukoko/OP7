@isTest
public class LivraisonControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test account and order
        Account account = TestDataFactory.createAccount('Test Livraison Account', 'Particulier');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        order.status = 'Activated';
        
        // Create test transporters with custom names
        Transporteur__c transporter1 = TestDataFactory.createTransporter('Cheap Transporter', 'Particulier;Professionnel', 'CT001');
        Transporteur__c transporter2 = TestDataFactory.createTransporter('Fast Transporter', 'Particulier;Professionnel', 'FT001');
        Transporteur__c transporter3 = TestDataFactory.createTransporter('Premium Transporter', 'Particulier', 'PT001');
        
        // Create test prices
        TestDataFactory.createPrice('France', transporter1.Id, 25.00, 5);
        TestDataFactory.createPrice('France', transporter2.Id, 50.00, 1);
        TestDataFactory.createPrice('France', transporter3.Id, 75.00, 2);
    }
    
    @isTest
    static void testCreateLivraisonWithCheapestTransporter_Success() {
        // Arrange
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = [SELECT Id, Pays__c, Tarif__c FROM Prix__c WHERE Tarif__c = 25.00 LIMIT 1];
        
        // Act
        Test.startTest();
        LivraisonController.createLivraisonWithCheapestTransporter(order, prix);
        Test.stopTest();
        
        // Assert
        List<Livraison__c> livraisons = [SELECT Id, Order__c, Statut__c FROM Livraison__c WHERE Order__c = :order.Id];
        Assert.areEqual(1, livraisons.size(), 'Should create one livraison');
        Assert.areEqual('En cours', livraisons[0].Statut__c, 'Livraison status should be "En cours"');
    }
    
    @isTest
    static void testCreateLivraisonWithFastestTransporter_Success() {
        // Arrange
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = [SELECT Id, Pays__c, Delai_De_Livraison__c FROM Prix__c WHERE Delai_De_Livraison__c = 1 LIMIT 1];
        
        // Act
        Test.startTest();
        LivraisonController.createLivraisonWithFastestTransporter(order, prix);
        Test.stopTest();
        
        // Assert
        List<Livraison__c> livraisons = [SELECT Id, Order__c, Statut__c FROM Livraison__c WHERE Order__c = :order.Id];
        Assert.areEqual(1, livraisons.size(), 'Should create one livraison');
        Assert.areEqual('En cours', livraisons[0].Statut__c, 'Livraison status should be "En cours"');
    }
    
    @isTest
    static void testCreateLivraisonWithSelectedTransporter_Success() {
        // Arrange
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = [SELECT Id, Pays__c FROM Prix__c LIMIT 1];
        
        // Act
        Test.startTest();
        LivraisonController.createLivraisonWithSelectedTransporter(order, prix);
        Test.stopTest();
        
        // Assert
        List<Livraison__c> livraisons = [SELECT Id, Order__c, Statut__c FROM Livraison__c WHERE Order__c = :order.Id];
        Assert.areEqual(1, livraisons.size(), 'Should create one livraison');
        Assert.areEqual('En cours', livraisons[0].Statut__c, 'Livraison status should be "En cours"');
    }
    
    @isTest
    static void testCreateCheapestLivraisonFromOrderId_Success() {
        // Arrange
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        // Act
        Test.startTest();
        LivraisonController.createCheapestLivraisonFromOrderId(order.Id);
        Test.stopTest();
        
        // Assert
        List<Livraison__c> livraisons = [SELECT Id, Order__c, Statut__c FROM Livraison__c WHERE Order__c = :order.Id];
        Assert.areEqual(1, livraisons.size(), 'Should create one livraison with cheapest transporter');
        Assert.areEqual('En cours', livraisons[0].Statut__c, 'Livraison status should be "En cours"');
    }
    
    
    @isTest
    static void testCreateFastestLivraisonFromOrderId_Success() {
        // Arrange
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        // Act
        Test.startTest();
        LivraisonController.createFastestLivraisonFromOrderId(order.Id);
        Test.stopTest();
        
        // Assert
        List<Livraison__c> livraisons = [SELECT Id, Order__c, Statut__c FROM Livraison__c WHERE Order__c = :order.Id];
        Assert.areEqual(1, livraisons.size(), 'Should create one livraison with fastest transporter');
    }
    
    
    @isTest
    static void testLivraisonFields_AreCorrect() {
        // Arrange
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = [SELECT Id, Pays__c FROM Prix__c LIMIT 1];
        
        // Act
        Test.startTest();
        LivraisonController.createLivraisonWithCheapestTransporter(order, prix);
        Test.stopTest();
        
        // Assert
        Livraison__c livraison = [SELECT Id, Order__c, Account__c, prix__c, Statut__c FROM Livraison__c LIMIT 1];
        Assert.areEqual(order.Id, livraison.Order__c, 'Order ID should match');
        Assert.areEqual(order.AccountId, livraison.Account__c, 'Account ID should match');
        Assert.areEqual(prix.Id, livraison.prix__c, 'Prix ID should match');
        Assert.areEqual('En cours', livraison.Statut__c, 'Status should be "En cours"');
    }
}
