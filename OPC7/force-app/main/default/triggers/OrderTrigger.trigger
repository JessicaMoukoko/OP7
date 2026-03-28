trigger OrderTrigger on Order (before insert, before update, after update) {
    
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