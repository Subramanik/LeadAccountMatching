/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-03-2025
 * @last modified by  : Subramani Kumarasamy
**/
public with sharing class TriggerDispatcher {

    @TestVisible
    private static Boolean doNotExecute = false;
    
    public static void createAndExecuteHandler(Type handlerType, System.TriggerOperation operationType, String sObjectType) {

        if (handlerType == null) {
            throw new TriggerDispatchException('TriggerDispatcher Error: No handler found for SObject [' + sObjectType + '].');
        }
        // Instantiate the type
        Object obj = handlerType.newInstance();
        if (!(obj instanceof TriggerHandlerInterface)) {
            throw new TriggerDispatchException('Provided class does not implement TriggerHandlerInterface: ' + handlerType.getName());
        }
        
        executeHandler((TriggerHandlerInterface) obj, operationType, sObjectType);
    }
    
    private static void executeHandler(TriggerHandlerInterface handler, System.TriggerOperation operationType, String sObjectType) {
        String triggerName = sObjectType + 'Trigger';
    
        // Check if trigger is active and user has permissions
        if (TriggerExecutionController.stopExecutionFromTrigger(doNotExecute, triggerName)) {
            return; // Trigger is inactive or user lacks permissions
        }
        // Dispatch to the appropriate handler method
        switch on operationType {
            when BEFORE_INSERT {
                handler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                handler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                handler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                handler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                handler.afterUndelete(Trigger.new, Trigger.newMap);
            }   
        }
    }

    public class TriggerDispatchException extends Exception {

    }
}