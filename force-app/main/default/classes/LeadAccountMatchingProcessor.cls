/**
 * @description This class processes incoming lead data and assigns matching accounts based on company names.
 * Last modified on  : 05-02-2025
 * Last modified by  : Subramani Kumarasamy
 * Last modified Reason : Initial version created to handle lead and account matching.
 **/
public with sharing class LeadAccountMatchingProcessor extends TriggerExecutionController {
    private static final String TRIGGER_NAME = 'LeadTrigger';
    private static final String TRIGGER_METHOD = 'LeadAccountMatchingProcessor';
    @TestVisible
    private static Boolean doNotExecuteLeadAccountMatchingProcessor = false;

    public static void processIncomingLeadData(List<Lead> newLeads) {
        if (newLeads == null || newLeads.isEmpty()) {
            return; // No leads to process
        }

        if(stopExecutionFromAction(doNotExecuteLeadAccountMatchingProcessor, TRIGGER_NAME, TRIGGER_METHOD)) {
            return; // Stop execution if the trigger is not active
        }
        
        List<Lead> newLeadToProcess = new List<Lead>();

        // Iterate through the new leads and add company names to the set
        for (Lead lead : newLeads) {
            if (lead.Company != null && lead.Email != null && lead.Account__C == null) {
                newLeadToProcess.add(lead);
            }
        }
        // Process the unique company names as needed
        if(!newLeadToProcess.isEmpty()) {
            LeadAccountMatchingService.assignMatchingAccount(newLeadToProcess);
        }
    }
}