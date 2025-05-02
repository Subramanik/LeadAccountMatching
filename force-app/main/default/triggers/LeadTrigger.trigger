/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-01-2025
 * @last modified by  : Subramani Kumarasamy
**/
trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    String sObjectName = Schema.SObjectType.Lead.getName();
    Type handlerType = TriggerExecutionController.getHandlerType(sObjectName);
    TriggerDispatcher.createAndExecuteHandler(handlerType, Trigger.operationType, sObjectName);
}