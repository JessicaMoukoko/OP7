@isTest
public class AccountSelectorTest {
    
    @isTest
    // Test de la méthode getAccountById pour un compte existant
    public static void testGetAccountById_Success() {
        
        // création d'un compte de test
        Account testAccount = TestDataFactory.createAccount('Test Account', 'Particulier');
        
        
        Test.startTest();
        Account AccountToTest = AccountSelector.getAccountById(testAccount.Id);
        Test.stopTest();

        // Assert
        Assert.isNotNull(AccountToTest, 'Account should not be null');
        Assert.areEqual(testAccount.Id, AccountToTest.Id, 'Account ID should match');
        Assert.areEqual('Test Account', AccountToTest.Name, 'Account name should match');
        Assert.areEqual('Particulier', AccountToTest.AccountType__c, 'Account type should match');
    }
    
    @isTest
    // Test de la méthode getAccountById pour un compte inexistant
    public static void testGetAccountById_Error() {
       
        Id invalidId = '001XX000003DHPOQAW'; // cet ID n'existe pas dans la base de données de test
        
    
       try {
            Account account = AccountSelector.getAccountById(invalidId);
            Assert.fail('Should throw an exception for invalid account ID');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('no rows for assignment'), 'Should throw QueryException');
        }
    }
}