public with sharing class OrderController {

    Account account = AccountSelector.getAccountById(order.AccountId);

     @AuraEnabled(cacheable=true)     
    // Récupérer les produits associés à une commande spécifique

    public static List<OrderItem> getOrderProducts(String OrderId) {

 List<OrderItem> OrderProducts = [
            SELECT Id,
                AccountId,
                Quantity,
                UnitPrice,
                TotalPrice,
                Product2Id,

            FROM OrderItem WHERE (orderId=:OrderId AND AccountId =: account.Id)
            WITH SECURITY_ENFORCED
        ];
        return OrderProducts;
    }
    
    // Méthode pour valider les commandes
    public static void validateOrder(Order orderToValidate) {

    Account AccountToValidate = AccountSelector.getAccountById(orderToValidate.AccountId);
    List<OrderItem> orderItems = getOrderProducts(orderToValidate.Id);
    boolean result = false;

// Logique de validation basée sur le type de compte et le nombre de produits associés à la commande

    if (AccountToValidate.AccountType__c == 'Particulier' && orderItems.size() >= 3)
    {
       result =  true ; 
    }
    else if (AccountToValidate.AccountType__c == 'Professionnel' && orderItems.size() >= 5)
    {
        result = true; 
    }
    else
    {
       return result ;
    }

    }

}