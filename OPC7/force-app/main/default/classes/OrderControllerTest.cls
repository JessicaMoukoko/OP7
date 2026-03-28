@isTest
public class OrderControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test products first
        Product2 product1 = TestDataFactory.createProduct('Test Product 1');
        Product2 product2 = TestDataFactory.createProduct('Test Product 2');
        Product2 product3 = TestDataFactory.createProduct('Test Product 3');
        Product2 product4 = TestDataFactory.createProduct('Test Product 4');
        Product2 product5 = TestDataFactory.createProduct('Test Product 5');
        
        // Create test price book entry
        PricebookEntry standardPBEntry = TestDataFactory.createPricebookEntry(
            Test.getStandardPricebookId(),
            product1.Id,
            100.00
        );

        // Create more pricebook entries for all products
        TestDataFactory.createPricebookEntry(Test.getStandardPricebookId(), product2.Id, 100.00);
        TestDataFactory.createPricebookEntry(Test.getStandardPricebookId(), product3.Id, 100.00);
        TestDataFactory.createPricebookEntry(Test.getStandardPricebookId(), product4.Id, 100.00);
        TestDataFactory.createPricebookEntry(Test.getStandardPricebookId(), product5.Id, 100.00);
        
        // Create test account
        Account account = TestDataFactory.createAccount('Test Account', 'Particulier');
        
        // Create order and items together within startTest/stopTest to manage trigger execution
        Test.startTest();
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Create order items to satisfy validation
        TestDataFactory.createOrderItem(order.Id, product1.Id, standardPBEntry.Id, 1, 100.00);
        TestDataFactory.createOrderItem(order.Id, product2.Id, standardPBEntry.Id, 1, 100.00);
        TestDataFactory.createOrderItem(order.Id, product3.Id, standardPBEntry.Id, 1, 100.00);
        Test.stopTest();
    }
    
    @isTest
    static void testGetOrderProducts_Success() {
        // Arrange
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        // Act
        test.startTest();
        List<OrderItem> products = OrderController.getOrderProducts(order.Id);
        test.stopTest();
        
        // Assert
        Assert.isNotNull(products, 'Order products list should not be null');
        Assert.areEqual(3, products.size(), 'Should return 3 order items');
    }
    
    @isTest
    static void testGetOrderProducts_NoProducts() {
        // Arrange
        Account account = TestDataFactory.createAccount('Empty Order Account', 'Particulier');
        Order emptyOrder = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Act
        test.startTest();
        List<OrderItem> products = OrderController.getOrderProducts(emptyOrder.Id);
        test.stopTest();
        
        // Assert
        Assert.isNotNull(products, 'List should not be null');
        Assert.areEqual(0, products.size(), 'Should return empty list for order with no items');
    }
    
    @isTest
    static void testGetOrderProducts_FieldsAreCorrect() {
        // Arrange
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        // Act
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
        // Arrange
        Account account = TestDataFactory.createAccount('Particulier Account', 'Particulier');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');

        
        // Create only 2 order items (less than minimum of 3)
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 2];
        for (Product2 product : products) {
            TestDataFactory.createOrderItem(order.Id, product.Id, pbe.Id, 1, 100.00);
        }
        
        Order orderToValidate = [SELECT Id, AccountId, Status FROM Order WHERE Id = :order.Id];
        
        // Act & Assert
        try {
            OrderController.validateOrder(orderToValidate);
            Assert.isTrue(orderToValidate.getErrors().size() > 0, 'Should have validation error for insufficient items');
        } catch (Exception e) {
            Assert.fail('Should not throw exception, should add error instead');
        }
    }
    
    @isTest
    static void testValidateOrder_ParticulierValidOrder() {
        // Arrange
        Account account = TestDataFactory.createAccount('Valid Particulier', 'Particulier');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Create 3 order items (meets minimum requirement)
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 3];
        for (Product2 product : products) {
            TestDataFactory.createOrderItem(order.Id, product.Id, pbe.Id, 1, 100.00);
        }
        
        Order orderToValidate = [SELECT Id, AccountId, Status FROM Order WHERE Id = :order.Id];
        
        // Act & Assert
        try {
            OrderController.validateOrder(orderToValidate);
            Assert.areEqual(0, orderToValidate.getErrors().size(), 'Valid order should have no errors');
        } catch (Exception e) {
            Assert.fail('Valid order should not throw exception');
        }
    }
    
    @isTest
    static void testValidateOrder_ProfessionnelMinimumItems() {
        // Arrange
        Account account = TestDataFactory.createAccount('Professionnel Account', 'Professionnel');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Create only 3 order items (less than minimum of 5)
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 3];
        for (Product2 product : products) {
            TestDataFactory.createOrderItem(order.Id, product.Id, pbe.Id, 1, 100.00);
        }
        
        Order orderToValidate = [SELECT Id, AccountId, Status FROM Order WHERE Id = :order.Id];
        
        // Act & Assert
        try {
            OrderController.validateOrder(orderToValidate);
            Assert.isTrue(orderToValidate.getErrors().size() > 0, 'Should have validation error for professional account with less than 5 items');
        } catch (Exception e) {
            Assert.fail('Should not throw exception, should add error instead');
        }
    }
    
    @isTest
    static void testValidateOrder_ProfessionnelValidOrder() {
        // Arrange
        Account account = TestDataFactory.createAccount('Valid Professionnel', 'Professionnel');
        Order order = TestDataFactory.createOrder(account.Id, 'Draft');
        
        // Create 5 order items (meets minimum requirement)
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 5];
        for (Product2 product : products) {
            TestDataFactory.createOrderItem(order.Id, product.Id, pbe.Id, 1, 100.00);
        }
        
        Order orderToValidate = [SELECT Id, AccountId, Status FROM Order WHERE Id = :order.Id];
        
        // Act & Assert
        try {
            OrderController.validateOrder(orderToValidate);
            Assert.areEqual(0, orderToValidate.getErrors().size(), 'Valid professional order should have no errors');
        } catch (Exception e) {
            Assert.fail('Valid order should not throw exception');
        }
    }
}
