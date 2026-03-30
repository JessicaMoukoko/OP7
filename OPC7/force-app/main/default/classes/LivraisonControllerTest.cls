@isTest
public class LivraisonControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Creation d'un compte, d'une commande
        Account account = TestDataFactory.createAccount('Test Livraison Account', 'Particulier');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        order.status = 'Activated';
        
        // Creation de transporteurs
        Transporteur__c transporter1 = TestDataFactory.createTransporter('Cheap Transporter', 'Particulier;Professionnel', 'CT001');
        Transporteur__c transporter2 = TestDataFactory.createTransporter('Fast Transporter', 'Particulier;Professionnel', 'FT001');
        Transporteur__c transporter3 = TestDataFactory.createTransporter('Premium Transporter', 'Particulier', 'PT001');
        
        // Creation de prix pour les transporteurs
        TestDataFactory.createPrice('France', transporter1.Id, 25.00, 5);
        TestDataFactory.createPrice('France', transporter2.Id, 50.00, 1);
        TestDataFactory.createPrice('France', transporter3.Id, 75.00, 2);
    }
    
    @isTest
    static void testCreateLivraisonWithCheapestTransporter_Success() {
        
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = [SELECT Id, Pays__c, Tarif__c FROM Prix__c WHERE Tarif__c = 25.00 LIMIT 1];
        
        //test de la création d'une livraison avec le transporteur le moins cher
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
        
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = [SELECT Id, Pays__c, Delai_De_Livraison__c FROM Prix__c WHERE Delai_De_Livraison__c = 1 LIMIT 1];
        
        // test de la création d'une livraison avec le transporteur le plus rapide
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
        
        Order order = [SELECT Id, AccountId, Account.AccountType__c FROM Order LIMIT 1];
        Prix__c prix = [SELECT Id, Pays__c FROM Prix__c LIMIT 1];
        
        // test de la création d'une livraison avec un transporteur sélectionné
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
        
        // test de la création d'une livraison avec le transporteur le moins cher à partir de l'ID de la commande
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
        
        // test de la création d'une livraison avec le transporteur le plus rapide à partir de l'ID de la commande
        
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
        
        // test de la création d'une livraison et vérification que les champs sont correctement renseignés
         
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

    @isTest
    static void testCreateLivraison_success() {

        User user = TestDataFactory.createUser();

        System.runAs(user) {

            Account acc = TestDataFactory.createAccount('Test Account', 'Professionnel');

            Order ord = TestDataFactory.createOrder(acc.Id, 'Draft');

            Transporteur__c transporter = TestDataFactory.createTransporter(
                'Transporteur 1',
                'Professionnel',
                'TR001'
            );

            Prix__c prix = TestDataFactory.createPrice(
                'France',
                transporter.Id,
                100,
                3
            );
       // test de la création d'une livraison avec un transporteur sélectionné
            Test.startTest();

            LivraisonController.createSelectedLivraisonFromOrderId(
                ord.Id,
                transporter.Id
            );

            Test.stopTest();

            List<Livraison__c> livraisons = [
                SELECT Id
                FROM Livraison__c
                WHERE Order__c = :ord.Id
            ];

            System.assertEquals(1, livraisons.size(),
                'A livraison should have been created');
        }
    }

    @isTest
    static void testCreateLivraison_noPrix() {

        User user = TestDataFactory.createUser();
     
        System.runAs(user) {
       

            Account acc = TestDataFactory.createAccount('Test Account', 'Professionnel');
            Order ord = TestDataFactory.createOrder(acc.Id, 'Draft');

            Transporteur__c transporter = TestDataFactory.createTransporter(
                'Transporteur 1',
                'Professionnel',
                'TR001'
            );

        // test de la création d'une livraison avec un transporteur sélectionné mais sans prix défini
            Test.startTest();

            try {
                LivraisonController.createSelectedLivraisonFromOrderId(
                    ord.Id,
                    transporter.Id
                );
                System.assert(false, 'Exception should have been thrown');
            } catch (AuraHandledException e) {
                System.assert(
                    e.getMessage().contains('Script'),
                    'Wrong exception message: ' + e.getMessage()
                );
            }

            Test.stopTest();
        }
    }
}
