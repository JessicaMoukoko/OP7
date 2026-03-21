trigger OrderTrigger on Order (before update, after update) {
    // Validate orders BEFORE update when OrderItems already exist
    // For before update, we can access the OrderItems since they were already created
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Order order : Trigger.new) {
            OrderController.validateOrder(order);
        }
    }

    // TODO: Select the best transporter based on the choice made on the order
}