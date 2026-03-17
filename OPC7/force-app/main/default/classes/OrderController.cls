public with sharing class OrderController {

     @AuraEnabled(cacheable=true)     

    // Récupérer les produits associés à une commande spécifique

    public static List<OrderItem> getOrderProducts(String OrderId) {

 List<OrderItem> OrderProducts = [SELECT Id,Order.accountId,
                Quantity,
                UnitPrice,
                TotalPrice,
                Product2Id,
                OrderName__c
            FROM OrderItem WHERE orderId=:OrderId 
            WITH SECURITY_ENFORCED
        ];
        return OrderProducts;
    }
    
    // Méthode pour valider les commandes

    public static void validateOrder(Order orderToValidate) {
        Account account = AccountSelector.getAccountById(orderToValidate.AccountId);

        List<OrderItem> orderItems = getOrderProducts(orderToValidate.Id);
        boolean result = true;

        // Validation basée sur le type de compte et le nombre d'articles
        if (orderToValidate.Status != 'Draft') {
            if (account.AccountType__c == 'Particulier' && orderItems.size() < 3) {
                orderToValidate.addError('Une commande d\'un particulier doit contenir au moins 3 articles');
                result = false;
            } else if (account.AccountType__c == 'Professionnel' && orderItems.size() < 5) {
                orderToValidate.addError('Une commande d\'un professionnel doit contenir au moins 5 articles');
                result= false;
            }
        }

    }
}