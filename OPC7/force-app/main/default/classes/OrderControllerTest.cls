@isTest
public class OrderControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test account
        Account account = new Account(
            Name = 'Test Account',
            Type = 'Prospect',
            AccountType__c = 'Particulier'
        );
        insert account;
        
        // Create test order
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert order;
        
        // Create test products
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(new Product2(
                Name = 'Test Product ' + i,
                IsActive = true
            ));
        }
        insert products;
        
        // Create test price book entries
        PricebookEntry standardPBEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = products[0].Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert standardPBEntry;
        
        // Create order items
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Integer i = 0; i < 3; i++) {
            orderItems.add(new OrderItem(
                OrderId = order.Id,
                Product2Id = products[i].Id,
                Quantity = 1,
                UnitPrice = 100.00,
                PricebookEntryId = standardPBEntry.Id
            ));
        }
        insert orderItems;
    }
    
    @isTest
    static void testGetOrderProducts_Success() {
        // Arrange
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        // Act
        List<OrderItem> products = OrderController.getOrderProducts(order.Id);
        
        // Assert
        Assert.isNotNull(products, 'Order products list should not be null');
        Assert.areEqual(3, products.size(), 'Should return 3 order items');
    }
    
    @isTest
    static void testGetOrderProducts_NoProducts() {
        // Arrange
        Account account = new Account(Name = 'Empty Order Account');
        insert account;
        Order emptyOrder = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert emptyOrder;
        
        // Act
        List<OrderItem> products = OrderController.getOrderProducts(emptyOrder.Id);
        
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
    static void testValidateOrder_Draft_NoValidation() {
        // Arrange
        Order order = new Order(
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        
        // Act & Assert
        try {
            OrderController.validateOrder(order);
            Assert.isTrue(true, 'Draft orders should not trigger validation');
        } catch (Exception e) {
            Assert.fail('Draft order validation should not throw an exception');
        }
    }
    
    @isTest
    static void testValidateOrder_ParticulierMinimumItems() {
        // Arrange
        Account account = new Account(
            Name = 'Particulier Account',
            Type = 'Prospect',
            AccountType__c = 'Particulier'
        );
        insert account;
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated'
        );
        insert order;
        
        // Create only 2 order items (less than minimum of 3)
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < 2; i++) {
            items.add(new OrderItem(
                OrderId = order.Id,
                Product2Id = product.Id,
                Quantity = 1,
                UnitPrice = 100.00,
                PricebookEntryId = pbe.Id
            ));
        }
        insert items;
        
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
        Account account = new Account(
            Name = 'Valid Particulier',
            Type = 'Prospect',
            AccountType__c = 'Particulier'
        );
        insert account;
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated'
        );
        insert order;
        
        // Create 3 order items (meets minimum requirement)
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < 3; i++) {
            items.add(new OrderItem(
                OrderId = order.Id,
                Product2Id = product.Id,
                Quantity = 1,
                UnitPrice = 100.00,
                PricebookEntryId = pbe.Id
            ));
        }
        insert items;
        
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
        Account account = new Account(
            Name = 'Professionnel Account',
            Type = 'Prospect',
            AccountType__c = 'Professionnel'
        );
        insert account;
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated'
        );
        insert order;
        
        // Create only 3 order items (less than minimum of 5)
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < 3; i++) {
            items.add(new OrderItem(
                OrderId = order.Id,
                Product2Id = product.Id,
                Quantity = 1,
                UnitPrice = 100.00,
                PricebookEntryId = pbe.Id
            ));
        }
        insert items;
        
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
        Account account = new Account(
            Name = 'Valid Professionnel',
            Type = 'Prospect',
            AccountType__c = 'Professionnel'
        );
        insert account;
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Activated'
        );
        insert order;
        
        // Create 5 order items (meets minimum requirement)
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < 5; i++) {
            items.add(new OrderItem(
                OrderId = order.Id,
                Product2Id = product.Id,
                Quantity = 1,
                UnitPrice = 100.00,
                PricebookEntryId = pbe.Id
            ));
        }
        insert items;
        
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
