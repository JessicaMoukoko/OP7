@isTest
public class OrderControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Creation de produits de test
        Product2 product1 = TestDataFactory.createProduct('Test Product 1');
        Product2 product2 = TestDataFactory.createProduct('Test Product 2');
        Product2 product3 = TestDataFactory.createProduct('Test Product 3');
        Product2 product4 = TestDataFactory.createProduct('Test Product 4');
        Product2 product5 = TestDataFactory.createProduct('Test Product 5');
        
        // Creation de pricebook entries pour les produits
        PricebookEntry standardPBEntry = TestDataFactory.createPricebookEntry(
            Test.getStandardPricebookId(),
            product1.Id,
            100.00
        );

        // Creation de pricebookentrys pour les produits
        TestDataFactory.createPricebookEntry(Test.getStandardPricebookId(), product2.Id, 100.00);
        TestDataFactory.createPricebookEntry(Test.getStandardPricebookId(), product3.Id, 100.00);
        TestDataFactory.createPricebookEntry(Test.getStandardPricebookId(), product4.Id, 100.00);
        TestDataFactory.createPricebookEntry(Test.getStandardPricebookId(), product5.Id, 100.00);
        
        
        Account account = TestDataFactory.createAccount('Test Account', 'Particulier');
        
        // Creation d'une commande de test pour le compte
        Test.startTest();
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Creation d'orderitems 
        TestDataFactory.createOrderItem(order.Id, product1.Id, standardPBEntry.Id, 1, 100.00);
        TestDataFactory.createOrderItem(order.Id, product2.Id, standardPBEntry.Id, 1, 100.00);
        TestDataFactory.createOrderItem(order.Id, product3.Id, standardPBEntry.Id, 1, 100.00);
        Test.stopTest();
    }
    
    @isTest
    static void testGetOrderProducts_Success() {
        
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        // test de la récupération des produits d'une commande

        Test.startTest();
        List<OrderItem> products = OrderController.getOrderProducts(order.Id);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(products, 'Order products list should not be null');
        Assert.areEqual(3, products.size(), 'Should return 3 order items');
    }
    
    @isTest
    static void testGetOrderProducts_NoProducts() {
        
        Account account = TestDataFactory.createAccount('Empty Order Account', 'Particulier');
        Order emptyOrder = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // test de la récupération des produits d'une commande qui ne contient aucun produit

        Test.startTest();
        List<OrderItem> products = OrderController.getOrderProducts(emptyOrder.Id);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(products, 'List should not be null');
        Assert.areEqual(0, products.size(), 'Should return empty list for order with no items');
    }
    
    @isTest
    static void testGetOrderProducts_FieldsAreCorrect() {
       
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        // test de la récupération des produits d'une commande et vérification que les champs sont correctement renseignés

        List<OrderItem> products = OrderController.getOrderProducts(order.Id);
        
        // Assert
        Assert.isTrue(products.size() > 0, 'Should have at least one product');
        OrderItem item = products[0];
        Assert.isNotNull(item.Id, 'OrderItem should have an ID');
        Assert.isNotNull(item.Product2Id, 'OrderItem should have a Product2Id');
        Assert.isNotNull(item.Quantity, 'OrderItem should have a Quantity');
        Assert.isNotNull(item.UnitPrice, 'OrderItem should have a UnitPrice');
    }
    
    
    @isTest
    static void testValidateOrder_ParticulierMinimumItems() {
       
        Account account = TestDataFactory.createAccount('Particulier Account', 'Particulier');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');

        
        // creation de seulement 2 commandes (moins que le minimum de 3 pour les particuliers)

        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 2];
        for (Product2 product : products) {
            TestDataFactory.createOrderItem(order.Id, product.Id, pbe.Id, 1, 100.00);
        }
        
        Order orderToValidate = [SELECT Id, AccountId, Status FROM Order WHERE Id = :order.Id];
        
        
        try {
            OrderController.validateOrder(orderToValidate);
            Assert.isTrue(orderToValidate.getErrors().size() > 0, 'Should have validation error for insufficient items');
        } catch (Exception e) {
            Assert.fail('Should not throw exception, should add error instead');
        }
    }
    
    @isTest 
    static void testValidateOrder_ParticulierValidOrder() {
        
        Account account = TestDataFactory.createAccount('Valid Particulier', 'Particulier');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Creation de 3 articles (minimum requis pour les particuliers)

        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 3];
        for (Product2 product : products) {
            TestDataFactory.createOrderItem(order.Id, product.Id, pbe.Id, 1, 100.00);
        }
        
        Order orderToValidate = [SELECT Id, AccountId, Status FROM Order WHERE Id = :order.Id];
        
        // try catch pour vérifier que la validation ne génère pas d'erreur pour une commande valide
        try {
            OrderController.validateOrder(orderToValidate);
            Assert.areEqual(0, orderToValidate.getErrors().size(), 'Valid order should have no errors');
        } catch (Exception e) {
            Assert.fail('Valid order should not throw exception');
        }
    }
    
    @isTest
    static void testValidateOrder_ProfessionnelMinimumItems() {
        
        Account account = TestDataFactory.createAccount('Professionnel Account', 'Professionnel');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Creation de 3 articles ( minimum requis 5 articles pour les professionnels)

        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 3];
        for (Product2 product : products) {
            TestDataFactory.createOrderItem(order.Id, product.Id, pbe.Id, 1, 100.00);
        }
        
        Order orderToValidate = [SELECT Id, AccountId, Status FROM Order WHERE Id = :order.Id];
        
        // try catch pour vérifier que la validation génère une erreur pour une commande professionnel avec moins de 5 articles
        try {
            OrderController.validateOrder(orderToValidate);
            Assert.isTrue(orderToValidate.getErrors().size() > 0, 'Should have validation error for professional account with less than 5 items');
        } catch (Exception e) {
            Assert.fail('Should not throw exception, should add error instead');
        }
    }
    
    @isTest
    static void testValidateOrder_ProfessionnelValidOrder() {
        
        Account account = TestDataFactory.createAccount('Valid Professionnel', 'Professionnel');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Creation de 5 articles ( 5 articles minimum requis pour les professionnels)

        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 5];
        for (Product2 product : products) {
            TestDataFactory.createOrderItem(order.Id, product.Id, pbe.Id, 1, 100.00);
        }
        
        Order orderToValidate = [SELECT Id, AccountId, Status FROM Order WHERE Id = :order.Id];
        
        // try catch pour vérifier que la validation ne génère pas d'erreur pour une commande professionnel valide
        try {
            OrderController.validateOrder(orderToValidate);
            Assert.areEqual(0, orderToValidate.getErrors().size(), 'Valid professional order should have no errors');
        } catch (Exception e) {
            Assert.fail('Valid order should not throw exception');
        }
    }
}
