@isTest
public with sharing class ProfileControllerTest {

    // Test de la méthode isResponsableCommercialUser

    @isTest
    public static void IsResponsableCommercialUserTest() {

PermissionSetAssignment psa = testDataFactory.CreatePermissionSetAssignmentResponsableCommercial();

Test.startTest();
Boolean isResponsableCommercial = ProfileController.isResponsableCommercialUser(psa.AssigneeId);
Test.stopTest();

System.assertequals(true,isResponsableCommercial);

}

// Test de la méthode isResponsableCommercialUser pour un utilisateur non responsable commercial

  @isTest
static void testNotResponsableCommercialUser() {
    User user = testDataFactory.createUser();

    // DO NOT assign permission set

    Boolean result = ProfileController.isResponsableCommercialUser(user.Id);

    System.assertEquals(false, result);
}
}