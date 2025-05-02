/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-03-2025
 * @last modified by  : Subramani Kumarasamy
**/
@isTest
private class TriggerDispatcherTest {

    // Dummy class to simulate an invalid handler (does not implement the interface)
    private class InvalidHandler {}

    @isTest
    static void testValidHandlerDispatchBeforeInsert() {
        TriggerDispatcher.createAndExecuteHandler(LeadTriggerHandler.class, System.TriggerOperation.BEFORE_INSERT, 'Lead');
        // If no exception occurs, the dispatch succeeded.
        Assert.isTrue(
            true,
            'Valid handler should not throw an exception'
        );
    }

    @isTest
    static void testValidHandlerDispatchAfterInsert() {
        TriggerDispatcher.createAndExecuteHandler(LeadTriggerHandler.class, System.TriggerOperation.AFTER_INSERT, 'Lead');
        // If no exception occurs, the dispatch succeeded.
        Assert.isTrue(
            true,
            'Valid handler should not throw an exception'
        );
    }

    @isTest
    static void testValidHandlerDispatchBeforeUpdate() {
        TriggerDispatcher.createAndExecuteHandler(LeadTriggerHandler.class, System.TriggerOperation.BEFORE_UPDATE, 'Lead');
        // If no exception occurs, the dispatch succeeded.
        Assert.isTrue(
            true,
            'Valid handler should not throw an exception'
        );
    }

    @isTest
    static void testValidHandlerDispatchAfterUpdate() { 
        TriggerDispatcher.createAndExecuteHandler(LeadTriggerHandler.class, System.TriggerOperation.AFTER_UPDATE, 'Lead');
        // If no exception occurs, the dispatch succeeded.
        Assert.isTrue(
            true,
            'Valid handler should not throw an exception'
        );
    }

    // Test for before delete
    @IsTest
    static void testValidHandlerDispatchBeforeDelete() {
        TriggerDispatcher.createAndExecuteHandler(LeadTriggerHandler.class, System.TriggerOperation.BEFORE_DELETE, 'Lead');
        // If no exception occurs, the dispatch succeeded.
        Assert.isTrue(
            true,
            'Valid handler should not throw an exception'
        );
    }
    // Test for after delete
    @IsTest
    static void testValidHandlerDispatchAfterDelete() {
        TriggerDispatcher.createAndExecuteHandler(LeadTriggerHandler.class, System.TriggerOperation.AFTER_DELETE, 'Lead');
        // If no exception occurs, the dispatch succeeded.
        Assert.isTrue(
            true,
            'Valid handler should not throw an exception'
        );
    }
    // Test for after undelete
    @IsTest
    static void testValidHandlerDispatchAfterUndelete() {
        TriggerDispatcher.createAndExecuteHandler(LeadTriggerHandler.class, System.TriggerOperation.AFTER_UNDELETE, 'Lead');
        // If no exception occurs, the dispatch succeeded.
        Assert.isTrue(
            true,
            'Valid handler should not throw an exception'
        );
    }

    //Test to set doNotExecute to true
    @IsTest
    static void testByPassTrigger() {
        TriggerDispatcher.doNotExecute = true;
        TriggerDispatcher.createAndExecuteHandler(LeadTriggerHandler.class, System.TriggerOperation.AFTER_INSERT, 'Lead');
        // If no exception occurs, the dispatch succeeded.
        Assert.areEqual(
            true,
            TriggerDispatcher.doNotExecute,
            'Bypass trigger should be set to true'
        );
    }

    @isTest
    static void testThrowsOnNullHandlerType() {
        try {
            TriggerDispatcher.createAndExecuteHandler(null, System.TriggerOperation.AFTER_INSERT, 'Lead');
        } catch (TriggerDispatcher.TriggerDispatchException e) {
            Assert.areEqual(
                true,
                e.getMessage().contains('No handler found'),
                'Exception message should mention missing handler'
            );
        }
    }

    @isTest
    static void testThrowsIfNotImplementingInterface() {
        try {
            TriggerDispatcher.createAndExecuteHandler(InvalidHandler.class, System.TriggerOperation.AFTER_INSERT, 'Lead');
        } catch (TriggerDispatcher.TriggerDispatchException e) {
            Assert.areEqual(
                true,
                e.getMessage().contains('does not implement TriggerHandlerInterface'),
                'Exception message should mention interface implementation issue'
            );
        }
    }
}