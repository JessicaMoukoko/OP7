@isTest
public class AccountSelectorTest {
    
    @isTest
    public static void testGetAccountById_Success() {
        // Arrange
        Account testAccount = TestDataFactory.createAccount('Test Account', 'Particulier');
        
        // Act
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
    public static void testGetAccountById_Error() {
        // Arrange
        Id invalidId = '001XX000003DHPOQAW'; // Assuming this ID does not exist in the test context
        
        // Act & Assert
       try {
            Account account = AccountSelector.getAccountById(invalidId);
            Assert.fail('Should throw an exception for invalid account ID');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('no rows for assignment'), 'Should throw QueryException');
        }
    }
}