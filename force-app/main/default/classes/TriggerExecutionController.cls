/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : Subramani Kumarasamy
**/
public virtual class TriggerExecutionController {

    private static Map<String, CustomMetadataTypeUtility.TriggerSettingWrapper> allTriggerSettings = CustomMetadataTypeUtility.getAllTriggerSettings();
    private static Map<String, Type> sObjectHandlerClass = new Map<String, Type>();
    @TestVisible
    private static Boolean isRunningTest = Test.isRunningTest();
    @TestVisible
    private static Boolean useMockPermissions = false;
    @TestVisible
    private static Set<String> mockGrantedPermissions = new Set<String>();

    /**
     * Determines whether to stop trigger execution based on settings and execution state.
     * @param doNotExecute default exectution value from calling class
     * @param triggerName Name of the trigger
     * @param triggerMethod Name of the trigger method (optional)
     * @return Boolean indicating whether to stop execution
     */
    public static Boolean stopExecutionFromTrigger(Boolean doNotExecute, String triggerName) {
        
        // If trigger has already executed, stop further execution
        if (doNotExecute) {
            return true;
        }
        
        CustomMetadataTypeUtility.TriggerSettingWrapper triggerSetting = allTriggerSettings.get(triggerName);
        // Check if trigger name exists
        if (triggerSetting == null || isRunningTest) {
            return false; // Trigger doesn't exist, allow execution
        }
        
        // Check trigger active status
        Boolean isTriggerActive = triggerSetting.isActive;
        
        if (!isTriggerActive) {
            return true; // Trigger is inactive, stop execution
        }
        
        // Check permissions (required and bypass)
        Boolean canExecute = checkPermissions(triggerSetting.requiredPermission, triggerSetting.bypassPermissions);
        if (!canExecute) {
            return true; // Permissions check failed, stop execution
        }
        return false; // All checks passed, allow execution
    }
    /**
     * Determines whether to stop trigger execution based on action settings and execution state.
     * @param doNotExecute default exectution value from calling class
     * @param triggerName Name of the trigger
     * @param triggerMethod Name of the trigger method (optional)
     * @return Boolean indicating whether to stop execution
     */
    public static Boolean stopExecutionFromAction(Boolean doNotExecute, String triggerName, String triggerMethod) {
        
        // If trigger has already executed, stop further execution
        if (doNotExecute) {
            return true;
        }

        CustomMetadataTypeUtility.TriggerSettingWrapper triggerSetting = allTriggerSettings.get(triggerName);

        System.debug('TriggerExecutionController: Trigger name: ' + triggerName);

        if (triggerSetting == null || isRunningTest) {
            return false; // No action setting, allow execution
        }

        if (!triggerSetting.actionSettings.containsKey(triggerMethod)) {
            return false; // No action setting, allow execution
        }

        SObjectTriggerActionSetting__mdt actionSetting = triggerSetting.actionSettings.get(triggerMethod);
        // Check action active status
        Boolean isTriggerActionActive = actionSetting.IsActive__c;
        
        if (!isTriggerActionActive) {
            return true; // Action is inactive, stop execution
        }
        
        // Check action permissions
        return !checkPermissions(actionSetting.Required_Permission__c, actionSetting.Bypass_Permissions__c);
    }
    /**
     * Checks if the user has the required permissions and does not have bypass permissions.
     * @param requiredPermissions Comma-separated list of required permissions
     * @param bypassPermissions Comma-separated list of bypass permissions
     * @return Boolean indicating whether the user has the required permissions
     */
    private static Boolean checkPermissions(String requiredPermissions, String bypassPermissions) {

        // If required permissions are specified, user must have ALL of them to proceed
        if (String.isNotBlank(requiredPermissions)) {
            List<String> requiredPerms = requiredPermissions.split(',');
            for (String perm : requiredPerms) {
                if (!checkPermission(perm.trim())) {
                    return false; // User lacks a required permission
                }
            }
            return true; // User has all required permissions
        }
        
        // If bypass permissions are specified, having ANY of them prevents execution
        if (String.isNotBlank(bypassPermissions)) {
            List<String> bypassPerms = bypassPermissions.split(',');
            for (String perm : bypassPerms) {
                if (checkPermission(perm.trim())) {
                    return false; // User has bypass permission, do not run
                }
            }
        }
        return true; // No required permissions, no bypass permissions matched
    }

    /**
     * Sets the mock permissions for testing purposes.
     * @param grantedPermissions Set of permissions to mock as granted
     * @param useMockPermissions Boolean indicating whether to use mock permissions
     * @return indicates whether to use mock permissions
     */
    public static Boolean checkPermission(String permissionName) {
        if (useMockPermissions) {
            return mockGrantedPermissions.contains(permissionName);
        }
        return FeatureManagement.checkPermission(permissionName);
    }

    /**
     * Retrieves the handler type for a given SObject name.
     * @param sObjectName Name of the SObject
     * @return Type of the handler class
     * @throws TriggerExecutionException if no handler is found
     */
    public static Type getHandlerType(String sObjectName) {
        if (sObjectHandlerClass.containsKey(sObjectName)) {
            return sObjectHandlerClass.get(sObjectName);
        }
        Type handlerType = Type.forName(sObjectName + 'TriggerHandler');
        if (handlerType == null) {
            throw new TriggerExecutionException('TriggerExecutionController Error: No handler found for SObject [' + sObjectName + '].');
        }
        sObjectHandlerClass.put(sObjectName, handlerType);
        return handlerType;
    }

    public class TriggerExecutionException extends Exception {
        
    }

}