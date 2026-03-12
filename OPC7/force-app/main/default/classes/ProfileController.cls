public with sharing class ProfileController {
      
      // Méthode pour vérifier si l'utilisateur est un responsable commercial

      @AuraEnabled(cacheable=true)
public static boolean IsResponsableCommercialUser(Id userId) {
      
        return FeatureManagement.checkPermission('ResponsableCommercial');
    }
    }