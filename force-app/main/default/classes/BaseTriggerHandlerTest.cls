/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : Subramani Kumarasamy
**/
@isTest
private class BaseTriggerHandlerTest {

    // Subclass that does NOT override any methods, so we can test BaseTriggerHandler directly
    private class PlainHandler extends BaseTriggerHandler {
        public Boolean testHasFieldChanged(SObject oldRecord, SObject newRecord, Schema.SObjectField field) {
            return hasFieldChanged(oldRecord, newRecord, field);
        }
    }

    @isTest
    static void testBaseHandlerDefaultImplementations() {
        PlainHandler handler = new PlainHandler();

        Lead lead1 = new Lead(FirstName = 'Base', LastName = 'Handler', Company = 'Acme');
        insert lead1;

        // Simulate old and new records for update/delete
        Lead oldLead = lead1.clone(false, true);
        oldLead.Id = lead1.Id;
        oldLead.FirstName = 'Original';

        Lead newLead = lead1.clone(false, true);
        newLead.FirstName = 'Modified';

        Map<Id, SObject> oldMap = new Map<Id, SObject>{ oldLead.Id => oldLead };
        Map<Id, SObject> newMap = new Map<Id, SObject>{ newLead.Id => newLead };

        // Call all base methods to ensure no exceptions
        handler.beforeInsert(new List<SObject>{ newLead });
        handler.beforeUpdate(new List<SObject>{ oldLead }, new List<SObject>{ newLead }, oldMap, newMap);
        handler.beforeDelete(new List<SObject>{ oldLead }, oldMap);
        handler.afterInsert(new List<SObject>{ newLead }, newMap);
        handler.afterUpdate(new List<SObject>{ oldLead }, new List<SObject>{ newLead }, oldMap, newMap);
        handler.afterDelete(new List<SObject>{ oldLead }, oldMap);
        handler.afterUndelete(new List<SObject>{ newLead }, newMap);

        // Assert no exceptions occurred; optionally, just assert true
        Assert.isTrue(true, 'Base handler methods should execute without error');
    }

    @isTest
    static void testHasFieldChangedMethod() {
        PlainHandler handler = new PlainHandler();

        Lead oldLead = new Lead(FirstName = 'A');
        Lead newLead = new Lead(FirstName = 'B');

        Boolean changed = handler.testHasFieldChanged(oldLead, newLead, Lead.FirstName);
        Assert.areEqual(true, changed, 'Expected change detected');

        newLead.FirstName = 'A';
        changed = handler.testHasFieldChanged(oldLead, newLead, Lead.FirstName);
        Assert.areEqual(false, changed, 'Expected no change');
    }
}