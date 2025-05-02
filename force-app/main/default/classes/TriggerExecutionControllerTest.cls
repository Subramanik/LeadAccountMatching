/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : Subramani Kumarasamy
**/
@isTest
private class TriggerExecutionControllerTest {

    private static void setupMockPermissions(Set<String> grantedPermissions) {
        TriggerExecutionController.isRunningTest = false;
        TriggerExecutionController.useMockPermissions = true;
        TriggerExecutionController.mockGrantedPermissions = grantedPermissions;
    }

    @TestSetup
    private static void setupMockTriggerMetadata() {
        // Construct fake metadata wrapper directly (instead of querying backend)
        Map<String, SObjectTriggerActionSetting__mdt> actions = new Map<String, SObjectTriggerActionSetting__mdt>();

        SObjectTriggerActionSetting__mdt mockAction = new SObjectTriggerActionSetting__mdt(
            DeveloperName = 'TEST_ACTION',
            IsActive__c = true,
            Required_Permission__c = 'Perm1',
            Bypass_Permissions__c = 'BypassPerm'
        );
        actions.put(mockAction.DeveloperName, mockAction);

        CustomMetadataTypeUtility.TriggerSettingWrapper mockWrapper = new CustomMetadataTypeUtility.TriggerSettingWrapper(
            'TEST_TRIGGER',
            true, // isActive
            'Mock trigger setting',
            'Perm1', // Required permission
            'BypassPerm', // Bypass permission
            actions
        );

        // Inject into utility map using @TestVisible variable
        Test.startTest();
        CustomMetadataTypeUtility.getAllTriggerSettings().clear(); // Ensure clean state
        CustomMetadataTypeUtility.getAllTriggerSettings().put('TEST_TRIGGER', mockWrapper);
        Test.stopTest();
    }

    @isTest static void testTriggerActiveActionNull() {
        setupMockPermissions(new Set<String>{ 'Perm1' });
        setupMockTriggerMetadata();

        Boolean result = TriggerExecutionController.stopExecutionFromAction(false, 'TEST_TRIGGER', 'INVALID_ACTION');
        Assert.areEqual(false, result, 'Should execute when action setting is missing');
    }

    @isTest static void testTriggerInactiveShouldStop() {
        setupMockPermissions(new Set<String>{ 'Perm1' });

        // Inactive trigger
        Map<String, SObjectTriggerActionSetting__mdt> actions = new Map<String, SObjectTriggerActionSetting__mdt>();
        CustomMetadataTypeUtility.TriggerSettingWrapper inactiveWrapper = new CustomMetadataTypeUtility.TriggerSettingWrapper(
            'INACTIVE_TRIGGER',
            false,
            'Inactive',
            null, null, actions
        );
        CustomMetadataTypeUtility.getAllTriggerSettings().put('INACTIVE_TRIGGER', inactiveWrapper);

        Boolean result = TriggerExecutionController.stopExecutionFromTrigger(false, 'INACTIVE_TRIGGER');
        Assert.areEqual(true, result, 'Should stop when trigger is inactive');
    }

    @isTest static void testTriggerPermissionMissingShouldStop() {
        setupMockPermissions(new Set<String>{ }); // No permission granted
        setupMockTriggerMetadata();

        Boolean result = TriggerExecutionController.stopExecutionFromTrigger(false, 'TEST_TRIGGER');
        Assert.areEqual(true, result, 'Should stop if required permission is missing');
    }

    @isTest static void testDoNotExecuteFlagShouldStopEarlyTrigger() {
        Boolean result = TriggerExecutionController.stopExecutionFromTrigger(true, 'TEST_TRIGGER');
        Assert.areEqual(true, result, 'Should stop immediately if doNotExecute is true');
    }

    @isTest static void testTriggerActionBypassPermissionShouldStop() {
        setupMockPermissions(new Set<String>{ 'BypassPerm' }); // Bypass permission granted
        setupMockTriggerMetadata();

        Boolean result = TriggerExecutionController.stopExecutionFromAction(false, 'TEST_TRIGGER', 'TEST_ACTION');
        Assert.areEqual(true, result, 'Should stop if bypass permission is granted');
    }

    @isTest static void testTriggerActionPermissionGrantedShouldExecute() {
        setupMockPermissions(new Set<String>{ 'Perm1' }); // Required permission granted
        setupMockTriggerMetadata();

        Boolean result = TriggerExecutionController.stopExecutionFromAction(false, 'TEST_TRIGGER', 'TEST_ACTION');
        Assert.areEqual(false, result, 'Should execute if required permission is granted');
    }

    @isTest static void testDoNotExecuteFlagShouldStopEarlyAction() {
        Boolean result = TriggerExecutionController.stopExecutionFromAction(true, 'TEST_TRIGGER', 'TEST_ACTION');
        Assert.areEqual(true, result, 'Should stop immediately if doNotExecute is true');
    }

    @isTest static void testBypassPermissionOnlyShouldStopExecution() {
        setupMockPermissions(new Set<String>{ 'BypassOnlyPerm' }); // Bypass permission granted
    
        Map<String, SObjectTriggerActionSetting__mdt> actions = new Map<String, SObjectTriggerActionSetting__mdt>();
        actions.put('BYPASS_ACTION', new SObjectTriggerActionSetting__mdt(
            DeveloperName = 'BYPASS_ACTION',
            IsActive__c = true,
            Required_Permission__c = null,
            Bypass_Permissions__c = 'BypassOnlyPerm'
        ));
    
        CustomMetadataTypeUtility.TriggerSettingWrapper wrapper = new CustomMetadataTypeUtility.TriggerSettingWrapper(
            'BYPASS_TRIGGER',
            true,
            'Trigger with bypass only',
            null,
            'BypassOnlyPerm',
            actions
        );
    
        CustomMetadataTypeUtility.getAllTriggerSettings().put('BYPASS_TRIGGER', wrapper);
    
        Boolean result = TriggerExecutionController.stopExecutionFromAction(false, 'BYPASS_TRIGGER', 'BYPASS_ACTION');
        Assert.areEqual(true, result, 'Should stop execution due to bypass permission');
    }

    // Method to test with inactive action

    @IsTest
    static void testInactiveAction() {
        setupMockPermissions(new Set<String>{ 'Perm1' });
        setupMockTriggerMetadata();
        // Inactive action
        Map<String, SObjectTriggerActionSetting__mdt> actions = new Map<String, SObjectTriggerActionSetting__mdt>();
        SObjectTriggerActionSetting__mdt inactiveAction = new SObjectTriggerActionSetting__mdt(
            DeveloperName = 'INACTIVE_ACTION',
            IsActive__c = false,
            Required_Permission__c = 'Perm1',
            Bypass_Permissions__c = 'BypassPerm'
        );
        actions.put(inactiveAction.DeveloperName, inactiveAction);
        CustomMetadataTypeUtility.TriggerSettingWrapper inactiveWrapper = new CustomMetadataTypeUtility.TriggerSettingWrapper(
            'INACTIVE_ACTION_TRIGGER',
            true,
            'Inactive action trigger',
            null, null, actions
        );
        CustomMetadataTypeUtility.getAllTriggerSettings().put('INACTIVE_ACTION_TRIGGER', inactiveWrapper);
        Boolean result = TriggerExecutionController.stopExecutionFromAction(false, 'INACTIVE_ACTION_TRIGGER', 'INACTIVE_ACTION');
        Assert.areEqual(true, result, 'Should stop when action is inactive');
    }

    // Method to test with no trigger metadata
    @IsTest
    static void testNoTriggerMetadata() {
        setupMockPermissions(new Set<String>{ 'Perm1' });
        // No trigger metadata
        Boolean result = TriggerExecutionController.stopExecutionFromTrigger(false, 'NO_METADATA_TRIGGER');
        Assert.areEqual(false, result, 'Should execute when no trigger metadata is present');
    }

    // Method to test with no trigger metadata but with out trigger action metadata
    @IsTest
    static void testNoTriggerMetadataNoAction() {
        setupMockPermissions(new Set<String>{ 'Perm1' });
        // No trigger metadata
        Boolean result = TriggerExecutionController.stopExecutionFromAction(false, 'NO_METADATA_TRIGGER', 'NO_ACTION');
        Assert.areEqual(false, result, 'Should execute when no trigger metadata is present');
    }

    // Method to test with trigger metadata but with out trigger action metadata
    @IsTest
    static void testTriggerMetadataWithoutAction() {
        setupMockPermissions(new Set<String>{ 'Perm1' });
        // Trigger metadata without action
        Map<String, SObjectTriggerActionSetting__mdt> actions = new Map<String, SObjectTriggerActionSetting__mdt>();
        CustomMetadataTypeUtility.TriggerSettingWrapper wrapper = new CustomMetadataTypeUtility.TriggerSettingWrapper(
            'TRIGGER_WITHOUT_ACTION',
            true,
            'Trigger without action',
            null,
            null,
            actions
        );
        CustomMetadataTypeUtility.getAllTriggerSettings().put('TRIGGER_WITHOUT_ACTION', wrapper);
        Boolean result = TriggerExecutionController.stopExecutionFromAction(false, 'TRIGGER_WITHOUT_ACTION', 'NON_EXISTENT_ACTION');
        Assert.areEqual(false, result, 'Should execute when trigger metadata exists but no action metadata');
    }

    // Dummy handler for testing
    public class MockSObjectTriggerHandler extends BaseTriggerHandler {}

    // Method to test handler type retrieval
    @isTest static void testGetHandlerTypevalid() {
        Type result = TriggerExecutionController.getHandlerType('Lead');
        Assert.areEqual('LeadTriggerHandler', String.valueOf(result), 'Handler type should match');
    }

    // Method to test handler type retrieval with invalid SObject
    @isTest static void testGetHandlerTypeInvalidShouldThrow() {
        try {
            TriggerExecutionController.getHandlerType('NoSuchSObject');
        } catch (TriggerExecutionController.TriggerExecutionException ex) {
            Assert.areEqual(true, ex.getMessage().contains(' No handler found for SObject'), 'Exception should be thrown for invalid SObject');
        }
    }
    
}