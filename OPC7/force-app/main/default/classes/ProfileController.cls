public with sharing class ProfileController {
      
      // Méthode pour vérifier si l'utilisateur est un responsable commercial

      @AuraEnabled(cacheable=true)
public static Boolean IsResponsableCommercialUser(Id userId) {

    List<PermissionSetAssignment> psa = [
        SELECT Id
        FROM PermissionSetAssignment
        WHERE AssigneeId = :userId
        AND PermissionSet.Name = 'ResponsableCommercial'
        LIMIT 1
    ];

    return !psa.isEmpty();
}
}