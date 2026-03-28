@isTest
public class TestDataFactory {
    
        // Crée un utilisateur de test avec le profil "System Administrator"

    public static User createUser() {
      Profile p = [
        SELECT Id
        FROM Profile
        WHERE Name = 'System Administrator'
        LIMIT 1
    ];
      // Crée l'utilisateur avec les champs obligatoires

    User user = new User(
        LastName = 'User Test',
        Username = 'testuser' + System.currentTimeMillis() + '@gmail.com',
        Email = 'testuser@gmail.com',
        Alias = 'tuser',
        TimeZoneSidKey = 'Europe/Paris',
        LocaleSidKey = 'fr_FR',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'fr',
        ProfileId = p.Id
    );
        insert user;
    return user ;

    }

    public static Account createAccount(String name, String accountType) {
        Account account = new Account(
            Name = name,
            Type = 'Prospect',
            Industry = 'Technology',
            BillingCity = 'Paris',
            BillingCountry = 'France',
            Phone = '0123456789',
            AccountType__c = accountType
        );
        insert account;
        return account;
    }
    
   
    public static Transporteur__c createTransporter(String name, String typeClient, String identifiant) {
      Transporteur__c transporter = new Transporteur__c(
            Name = name,
            Type_Client__c = typeClient,
            Identifiant__c = identifiant
        );
        insert transporter;
        return transporter;
    }
    
    
    public static Prix__c createPrice(String country, Id transporterId, Decimal price, Integer deliveryDays) {
        Prix__c priceEntry = new Prix__c(
            Pays__c = country,
            Transporteur__c = transporterId,
            Tarif__c = price,
            Delai_De_Livraison__c = deliveryDays
        );
        insert priceEntry;
        return priceEntry;
    }
    
    
    public static Order createOrder(Id accountId, String status) {
        Order order =   new Order(
            AccountId = accountId,
            EffectiveDate = Date.today(),
            Status = status,
            Pricebook2Id = Test.getStandardPricebookId(),
            BillingCity = 'Paris',
            BillingCountry = 'France',
            BillingPostalCode = '75001',
            BillingStreet = '1 Rue de Test'
        );
        insert order;
        return order;
    }
   
    public static Product2 createProduct(String name) {
        Product2 product = new Product2(
            Name = name,
            IsActive = true
        );
        insert product;
        return product;
    }
    
    public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId, Decimal unitPrice) {
        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert entry;
        return entry;
    }
    
    public static OrderItem createOrderItem(Id orderId, Id productId, Id pricebookEntryId, Integer quantity, Decimal unitPrice) {
        OrderItem item = new OrderItem(
            OrderId = orderId,
            Product2Id = productId,
            Quantity = quantity,
            UnitPrice = unitPrice,
            PricebookEntryId = pricebookEntryId
        );
        insert item;
        return item;
    }


     // crée une permission set assignment pour un utilisateur responsable commercial

    public static PermissionSetAssignment CreatePermissionSetAssignmentResponsableCommercial() {

      User user = createUser();
      Id userId = user.Id; // on récupère l'Id de l'utilisateur créé

     String permSetApiName = 'ResponsableCommercial';

     PermissionSet ps = [
        SELECT Id,Name
        FROM PermissionSet
        WHERE Name = :permSetApiName
        LIMIT 1
      ];

   PermissionSetAssignment psa = new PermissionSetAssignment(
    AssigneeId = userId,
    PermissionSetId = ps.Id
   );

insert psa;
return psa;
}

// crée une permission set assignment pour un utilisateur non responsable commercial


    public static PermissionSetAssignment CreatePermissionSetAssignmentNotResponsableCommercial() {

  User user = createUser();
  Id userId = user.Id;

  String permSetApiName = 'NotResponsableCommercial';

  PermissionSet ps = [
     SELECT Id,Name
     FROM PermissionSet
     WHERE Name = :permSetApiName
    LIMIT 1
];

PermissionSetAssignment psa = new PermissionSetAssignment(
    AssigneeId = userId,
    PermissionSetId = ps.Id
);

insert psa;
return psa;
}

}

