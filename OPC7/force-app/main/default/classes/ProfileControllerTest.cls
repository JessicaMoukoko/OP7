@isTest
public with sharing class ProfileControllerTest {

    // Test de la méthode isResponsableCommercialUser

    @isTest
    public static void IsResponsableCommercialUserTest() {

PermissionSetAssignment psa = testDataFactory.CreatePermissionSetAssignmentResponsableCommercial();

 // test de la méthode isResponsableCommercialUser pour un utilisateur qui est responsable commercial

Test.startTest();
Boolean isResponsableCommercial = ProfileController.isResponsableCommercialUser(psa.AssigneeId);
Test.stopTest();

System.assertequals(true,isResponsableCommercial);

}


  @isTest
static void testNotResponsableCommercialUser() {
    User user = testDataFactory.createUser();

    // Test de la méthode isResponsableCommercialUser pour un utilisateur qui n'est pas responsable commercial 
Test.startTest();
    Boolean result = ProfileController.isResponsableCommercialUser(user.Id);
Test.stopTest();

    System.assertEquals(false, result);
}
}