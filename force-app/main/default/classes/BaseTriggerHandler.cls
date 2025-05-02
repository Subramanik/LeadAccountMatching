/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-01-2025
 * @last modified by  : Subramani Kumarasamy
**/
@SuppressWarnings('PMD')
public virtual class BaseTriggerHandler implements TriggerHandlerInterface {
    
    public virtual void beforeInsert(List<SObject> newRecords) {
        // Default implementation (can be overridden)
    }
    public virtual void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<Id, SObject> oldRecordMap, Map<Id, SObject> newRecordMap) {
        // Default implementation (can be overridden)
    }
    public virtual void beforeDelete(List<SObject> oldRecords, Map<Id, SObject> oldRecordMap) {
        // Default implementation (can be overridden)
    }
    public virtual void afterInsert(List<SObject> newRecords, Map<Id, SObject> newRecordMap) {
        // Default implementation (can be overridden)
    }
    public virtual void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<Id, SObject> oldRecordMap, Map<Id, SObject> newRecordMap) {
        // Default implementation (can be overridden)
    }
    public virtual void afterDelete(List<SObject> oldRecords, Map<Id, SObject> oldRecordMap) {
        // Default implementation (can be overridden)
    }
    public virtual void afterUndelete(List<SObject> newRecords, Map<Id, SObject> newRecordMap) {
        // Default implementation (can be overridden)
    }

    /**
     * Check if a field has changed between two SObject records.
     * @param oldRecord The old SObject record.
     * @param newRecord The new SObject record.
     * @param field The field to check.
     * @return True if the field has changed, false otherwise.
     */
    protected Boolean hasFieldChanged(SObject oldRecord, SObject newRecord, Schema.SObjectField field) {
        return oldRecord?.get(field) != newRecord?.get(field);
    }

}