
public with sharing class AccountSelector {

    // Méthode pour récupérer un compte par son ID

    public static Account getAccountById(Id accountId) {
        return [
                SELECT Id, Name, Type, Industry, BillingCity, BillingCountry, Phone, AccountType__c
                FROM Account
                WHERE Id = :accountId
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
    }
}