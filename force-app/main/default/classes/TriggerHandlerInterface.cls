/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-01-2025
 * @last modified by  : Subramani Kumarasamy
**/
@SuppressWarnings('PMD')
public interface TriggerHandlerInterface {
    
    /**
     * Called before new records are inserted.
     * @param newRecords List of SObjects being inserted.
     */
    void beforeInsert(List<SObject> newRecords);

    /**
     * Called before existing records are updated.
     * @param oldRecords List of SObjects being updated.
     * @param newRecords List of new SObjects.
     * @param oldRecordMap Map of old SObjects by Id.
     * @param newRecordMap Map of new SObjects by Id.
     */
    void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<Id, SObject> oldRecordMap, Map<Id, SObject> newRecordMap);

    /**
     * Called before existing records are deleted.
     * @param oldRecords List of SObjects being deleted.
     * @param oldRecordMap Map of old SObjects by Id.
     */
    void beforeDelete(List<SObject> oldRecords, Map<Id, SObject> oldRecordMap);

    /**
     * Called after new records are inserted.
     * @param newRecords List of SObjects that were inserted.
     * @param newRecordMap Map of new SObjects by Id.
     */
    void afterInsert(List<SObject> newRecords, Map<Id, SObject> newRecordMap);

    /**
     * Called after existing records are updated.
     * @param oldRecords List of old SObjects.
     * @param newRecords List of new SObjects.
     * @param oldRecordMap Map of old SObjects by Id.
     * @param newRecordMap Map of new SObjects by Id.
     */
    void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<Id, SObject> oldRecordMap, Map<Id, SObject> newRecordMap);

    /**
     * Called after existing records are deleted.
     * @param oldRecords List of SObjects that were deleted.
     * @param oldRecordMap Map of old SObjects by Id.
     */
    void afterDelete(List<SObject> oldRecords, Map<Id, SObject> oldRecordMap);
    
    /**
     * Called after existing records are undeleted.
     * @param newRecords List of SObjects that were undeleted.
     * @param newRecordMap Map of new SObjects by Id.
     */
    void afterUndelete(List<SObject> newRecords, Map<Id, SObject> newRecordMap);
}