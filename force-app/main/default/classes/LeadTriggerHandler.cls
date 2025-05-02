/**
 * @description Trigger handler for Lead object
 * @last modified on  : 05-02-2025
 * @last modified by  : Subramani Kumarasamy
 * Last modified Reason : Initial version created to handle lead and account matching.
 */
public with sharing class LeadTriggerHandler extends BaseTriggerHandler {
    
    public override void beforeInsert(List<SObject> newRecords) {
        List<Lead> newLeads = (List<Lead>) newRecords;
        // call the processor class to process Incoming Lead Data
        LeadAccountMatchingProcessor.processIncomingLeadData(newLeads);
    }
}