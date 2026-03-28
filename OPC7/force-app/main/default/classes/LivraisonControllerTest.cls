@isTest
public class LivraisonControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test account
        Account account = new Account(
            Name = 'Test Livraison Account',
            Type = 'Prospect',
            AccountType__c = 'Particulier'
        );
        insert account;
        
        // Create test transporters
        List<Transporteur__c> transporters = new List<Transporteur__c>();
        transporters.add(new Transporteur__c(
            Name = 'Cheap Transporter',
            Type_Client__c = 'Particulier;Professionnel',
            Identifiant__c = 'CT001'
        ));
        transporters.add(new Transporteur__c(
            Name = 'Fast Transporter',
            Type_Client__c = 'Particulier;Professionnel',
            Identifiant__c = 'FT001'
        ));
        transporters.add(new Transporteur__c(
            Name = 'Premium Transporter',
            Type_Client__c = 'Particulier',
            Identifiant__c = 'PT001'
        ));
        insert transporters;
        
        // Create test prices
        List<Prix__c> prices = new List<Prix__c>();
        prices.add(new Prix__c(
            Pays__c = 'France',
            Transporteur__c = transporters[0].Id,
            Tarif__c = 25.00,
            Delai_De_Livraison__c = 5
        ));
        prices.add(new Prix__c(
            Pays__c = 'France',
            Transporteur__c = transporters[1].Id,
            Tarif__c = 50.00,
            Delai_De_Livraison__c = 1
        ));
        prices.add(new Prix__c(
            Pays__c = 'France',
            Transporteur__c = transporters[2].Id,
            Tarif__c = 75.00,
            Delai_De_Livraison__c = 2
        ));
        insert prices;
        
        // Create test order with billing address
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated',
            BillingCity = 'Paris',
            BillingCountry = 'France',
            BillingPostalCode = '75001',
            BillingStreet = '1 Rue de Test'
        );
        insert order;
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
    static void testCreateCheapestLivraisonFromOrderId_InvalidOrderId() {
        // Act & Assert
        try {
            Test.startTest();
            LivraisonController.createCheapestLivraisonFromOrderId('Invalid');
            Test.stopTest();
            Assert.fail('Should throw AuraHandledException for invalid order ID');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Erreur'), 'Should throw error with appropriate message');
        }
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
    static void testCreateLivraisonWithCheapestTransporter_NullTransporter() {
        // Arrange
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = new Prix__c(
            Pays__c = 'NonExistent',
            Tarif__c = 100.00,
            Delai_De_Livraison__c = 10
        );
        insert prix;
        
        // Act
        Test.startTest();
        LivraisonController.createLivraisonWithCheapestTransporter(order, prix);
        Test.stopTest();
        
        // Assert
        List<Livraison__c> livraisons = [SELECT Id FROM Livraison__c WHERE Order__c = :order.Id];
        Assert.areEqual(0, livraisons.size(), 'Should not create livraison if no transporter is found');
    }
    
    @isTest
    static void testCreateLivraisonWithFastestTransporter_NullTransporter() {
        // Arrange
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = new Prix__c(
            Pays__c = 'NonExistent',
            Tarif__c = 100.00,
            Delai_De_Livraison__c = 10
        );
        insert prix;
        
        // Act
        Test.startTest();
        LivraisonController.createLivraisonWithFastestTransporter(order, prix);
        Test.stopTest();
        
        // Assert
        List<Livraison__c> livraisons = [SELECT Id FROM Livraison__c WHERE Order__c = :order.Id];
        Assert.areEqual(0, livraisons.size(), 'Should not create livraison if no transporter is found');
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
