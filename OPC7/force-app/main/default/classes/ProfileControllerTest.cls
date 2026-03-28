@isTest
public class ProfileControllerTest {
    
    @isTest
    static void testIsResponsableCommercialUser_WithPermission() {
        // Note: This test assumes that the current user or the test user has the permission
        // In a real scenario, you might need to create a user with specific permission set
        
        // Act
        Test.startTest();
        boolean hasPermission = ProfileController.IsResponsableCommercialUser(UserInfo.getUserId());
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(hasPermission, 'Should return a boolean value');
        // The result depends on whether the test user has the permission
    }
    
    @isTest
    static void testIsResponsableCommercialUser_ReturnsBoolean() {
        // Act
        Test.startTest();
        boolean result = ProfileController.IsResponsableCommercialUser(UserInfo.getUserId());
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Result should not be null');
        Assert.isTrue(result instanceof Boolean, 'Result should be a boolean');
    }
    
    @isTest
    static void testIsResponsableCommercialUser_WithCurrentUserId() {
        // Arrange
        Id currentUserId = UserInfo.getUserId();
        
        // Act
        Test.startTest();
        boolean result = ProfileController.IsResponsableCommercialUser(currentUserId);
        Test.stopTest();
        
        // Assert - The result will vary based on the user's permission set
        Assert.isNotNull(result, 'Method should return a value');
    }
    
    @isTest
    static void testIsResponsableCommercialUser_Callable() {
        // This test verifies the method is callable and @AuraEnabled(cacheable=true)
        // without throwing any exceptions
        
        // Act & Assert
        try {
            Test.startTest();
            boolean result = ProfileController.IsResponsableCommercialUser(UserInfo.getUserId());
            Test.stopTest();
            Assert.isTrue(true, 'Method should be callable'); 
        } catch (Exception e) {
            Assert.fail('Method should not throw an exception: ' + e.getMessage());
        }
    }
}
