@isTest
public with sharing class ProfileControllerTest {

    // Test de la méthode isResponsableCommercialUser

    @isTest
    public static void IsResponsableCommercialUserTest() {

User user = testDataFactory.createUser();
PermissionSetAssignment psa = testDataFactory.CreatePermissionSetAssignmentResponsableCommercial();

Test.startTest();
Boolean isResponsableCommercial = ProfileController.isResponsableCommercialUser(user.Id);
Test.stopTest();

System.assertequals(true,isResponsableCommercial);

}

// Test de la méthode isResponsableCommercialUser pour un utilisateur non responsable commercial

    @isTest
public static void IsNotResponsableCommercialUserTest() {

User user = testDataFactory.createUser();
PermissionSetAssignment psa = testDataFactory.CreatePermissionSetAssignmentNotResponsableCommercial();

try {
   ProfileController.isResponsableCommercialUser(user.Id);
    }

catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('no rows for assignment'), 'Should throw QueryException');
        }
}
}