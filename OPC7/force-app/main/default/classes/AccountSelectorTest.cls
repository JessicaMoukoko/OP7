@isTest
public class AccountSelectorTest {
    
    @isTest
    static void testGetAccountById_Success() {
        // Arrange
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Prospect',
            Industry = 'Technology',
            BillingCity = 'Paris',
            BillingCountry = 'France',
            Phone = '0123456789',
            AccountType__c = 'Particulier'
        );
        insert testAccount;
        
        // Act
        Account retrievedAccount = AccountSelector.getAccountById(testAccount.Id);
        
        // Assert
        Assert.isNotNull(retrievedAccount, 'Account should not be null');
        Assert.areEqual(testAccount.Id, retrievedAccount.Id, 'Account ID should match');
        Assert.areEqual('Test Account', retrievedAccount.Name, 'Account name should match');
        Assert.areEqual('Particulier', retrievedAccount.AccountType__c, 'Account type should match');
    }
    
    @isTest
    static void testGetAccountById_InvalidId() {
        // Arrange
        Id invalidId = '001XX000003DHP';
        
        // Act & Assert
        try {
            Account account = AccountSelector.getAccountById(invalidId);
            Assert.fail('Should throw an exception for invalid account ID');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('No rows for assignment'), 'Should throw QueryException');
        }
    }
    
    @isTest
    static void testGetAccountById_MultipleFields() {
        // Arrange
        Account testAccount = new Account(
            Name = 'Enterprise Account',
            Type = 'Customer',
            Industry = 'Finance',
            BillingCity = 'Lyon',
            BillingCountry = 'France',
            Phone = '0456789123',
            AccountType__c = 'Professionnel'
        );
        insert testAccount;
        
        // Act
        Account retrievedAccount = AccountSelector.getAccountById(testAccount.Id);
        
        // Assert
        Assert.areEqual('Enterprise Account', retrievedAccount.Name, 'Name should match');
        Assert.areEqual('Finance', retrievedAccount.Industry, 'Industry should match');
        Assert.areEqual('Lyon', retrievedAccount.BillingCity, 'Billing city should match');
        Assert.areEqual('0456789123', retrievedAccount.Phone, 'Phone should match');
        Assert.areEqual('Professionnel', retrievedAccount.AccountType__c, 'Account type should match');
    }
}
