trigger OrderTrigger on Order (before insert, before update, after update) {

    // Avant l'insertion ou la mise à jour d'une commande, on vérifie si le statut de la commande passe de "Draft" à un autre statut. Si c'est le cas, 
    on appelle la méthode de validation de la commande.
    
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (Order order : Trigger.new) {
            if (Trigger.isUpdate) {
                Order oldOrder = Trigger.oldMap.get(order.Id);
                if (oldOrder.Status == 'Draft' && order.Status != 'Draft') {
                    OrderController.validateOrder(order);
                }
            }
        }
    }
}