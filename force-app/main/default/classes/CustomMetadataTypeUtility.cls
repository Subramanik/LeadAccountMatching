/**
 * @description : Utility class to handle custom metadata types for trigger settings and company name synonyms.
 * @last modified on  : 05-02-2025
 * @last modified by  : Subramani Kumarasamy
 * Last modified Reason : Initial version created to handle custom metadata types.
 * This class provides methods to retrieve trigger settings and company name synonyms from custom metadata types.
 * It caches the results for performance optimization.
 */
public with sharing class CustomMetadataTypeUtility {
    
    @TestVisible
    private static Map<String, TriggerSettingWrapper> triggerSettings = new Map<String, TriggerSettingWrapper>();
    @TestVisible
    private static Map<String, String> companyNameSynonymMap;
    @TestVisible
    private static Boolean useMockPermissions = false;
    @TestVisible
    private static Set<String> mockGrantedPermissions = new Set<String>();

    /**
     * @description : Retrieves company name synonyms from custom metadata type.
     * @return : Map of original company names to their synonyms
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     * Last modified Reason : Initial version created to handle company name synonyms.
     */
    public static Map<String, String> getCompanyNameSynonyms() {
        if (companyNameSynonymMap == null) {
            loadCompanyNameSynonyms();
        }
        return companyNameSynonymMap;
    }
    
    /**
     * @description : Retrieves all trigger settings from custom metadata type.
     * @return : Map of trigger names to their settings
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     * Last modified Reason : Initial version created to handle trigger settings.
     */
    public static Map<String, TriggerSettingWrapper> getAllTriggerSettings() {
        if (triggerSettings.isEmpty()) {
            loadTriggerSettings();
        }
        return triggerSettings;
    }
    /**
     * @description : Loads company name synonyms from custom metadata type.
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     * Last modified Reason : Initial version created to handle company name synonyms.
     */
    private static void loadCompanyNameSynonyms() {
        companyNameSynonymMap = new Map<String, String>();
        for (CompanyNameSynonym__mdt record : [SELECT Original__c, Replacement__c FROM CompanyNameSynonym__mdt]) {
            if (!String.isBlank(record.Original__c) && !String.isBlank(record.Replacement__c)) {
                companyNameSynonymMap.put(record.Original__c.toLowerCase().trim(), record.Replacement__c.toLowerCase().trim());
            }
        }
    }

    /**
     * @description : Loads trigger settings from custom metadata type.
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     * Last modified Reason : Initial version created to handle trigger settings.
     */
    private static void loadTriggerSettings() {
        for (SObjectTriggerSetting__mdt setting : [
            SELECT DeveloperName, IsActive__c, Description__c, Required_Permission__c, Bypass_Permissions__c,
                   (SELECT DeveloperName, IsActive__c, Required_Permission__c, Bypass_Permissions__c FROM SObjectTriggerActionSettings__r)
            FROM SObjectTriggerSetting__mdt
        ]) {
            if (setting == null) {
                continue; // Skip if no setting found
                
            }
            addSetting(setting);
        }
    }

    /**
     * @description : Adds a trigger setting to the map.
     * @param setting : The trigger setting to add
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     * Last modified Reason : Initial version created to handle trigger settings.
     */
    private static void addSetting(SObjectTriggerSetting__mdt setting) {
        Map<String, SObjectTriggerActionSetting__mdt> actions = new Map<String, SObjectTriggerActionSetting__mdt>();
        for (SObjectTriggerActionSetting__mdt action : setting.SObjectTriggerActionSettings__r) {
            actions.put(action.DeveloperName, action);
        }

        triggerSettings.put(setting.DeveloperName, 
            new TriggerSettingWrapper(
                setting.DeveloperName, 
                setting.IsActive__c, 
                setting.Description__c,
                setting.Required_Permission__c,
                setting.Bypass_Permissions__c,
                actions
            )
        );
    }
    
    public class TriggerSettingWrapper {
        public String triggerName;
        public Boolean isActive;
        public String description;
        public String requiredPermission;
        public String bypassPermissions;
        public Map<String, SObjectTriggerActionSetting__mdt> actionSettings;

        public TriggerSettingWrapper(String triggerName, Boolean isActive, String description, String requiredPermission, String bypassPermissions, Map<String, SObjectTriggerActionSetting__mdt> actionSettings) {
            this.triggerName = triggerName;
            this.isActive = isActive;
            this.description = description;
            this.requiredPermission = requiredPermission;
            this.bypassPermissions = bypassPermissions;
            this.actionSettings = actionSettings; 
        }
    }
}