/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : Subramani Kumarasamy
**/
@isTest
private class LeadAccountMatchingServiceTest {

    @TestSetup
    static void setupTestData() {

        List<Account> accounts = new List<Account>();
        accounts.add(DataFactory.createAccount('Test Company Inc', 'www.testcompany.com'));
        accounts.add(DataFactory.createAccount('Acme Corp', 'www.acmecorp.com'));
        accounts.add(DataFactory.createAccount('Flipkart', 'www.flipkart.com')); // Fuzzy match
        accounts.add(DataFactory.createAccount('Company Name Match Only', 'www.namematchonly.com'));
        accounts.add(DataFactory.createAccount('Special Ch@r Co', 'www.specialchar.com'));
        accounts.add(DataFactory.createAccount('Similarity Threshold Co', 'www.similaritythreshold.com')); // Similarity threshold
        accounts.add(DataFactory.createAccount('No Website Co', null)); // For null website 
        insert accounts;
    }
    
    @isTest
    static void testPositiveExactAndDomainMatch() {
        // Positive: Match both exact company name and email domain

        Lead lead =DataFactory.createLead(
            'Test',
            'Test Company Inc', // Exact name
            'test@testcompany.com' // Exact domain
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Test Company Inc' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, lead.Account__c, 'Lead should match based on fuzzy name and domain');
    }

    @isTest
    static void testPositiveFuzzyAndDomainMatch() {
        // Positive: Match both fuzzy company name and email domain
        Lead lead =DataFactory.createLead(
            'Test',
            'Test Compny Inc', // Intentional typo
            'test@testcompany.com'
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Test Company Inc' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, lead.Account__c, 'Lead should match based on fuzzy name and domain');
    }

    @isTest
    static void testPositiveFuzzyExtraAndDomainMatch() {
        // Positive: Match both fuzzy extra company name and email domain
        Lead lead =DataFactory.createLead(
            'Test',
            'Test Company1 Inc', // Intentional typo
            'test@testcompany.com'
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Test Company Inc' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, lead.Account__c, 'Lead should match based on fuzzy name and domain');
    }
    
    @isTest
    static void testPositiveFuzzyMatchOnly() {
        // Positive: Match on fuzzy company name and domain match
        Lead lead =DataFactory.createLead(
            'Test',
            'Acme Corp Ltd', // Fuzzy match
            'test@acmecorp.com' // Exact Domain match
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Acme Corp' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, lead.Account__c, 'Lead should match based on fuzzy name only');
    }

    @isTest
    static void testEdgeCaseLevenshteinSimilarityEqualsThreshold() {
   
    // Create a lead with slightly modified name to match exactly at threshold
    // For example: 'Similariy Threshol Co' has a Levenshtein distance of 2 vs original (length 26), similarity ~92.3%
    String fuzzyName = 'Similariy Threshol Co';
    String domain = 'similaritythreshold.com';
    Lead lead = DataFactory.createLead('Test', fuzzyName, 'test@' + domain);
    insert lead;

    // Fetch the matched account
    Lead updatedLead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
    Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Similarity Threshold Co' LIMIT 1];
    Assert.areEqual(matchedAccount.Id, updatedLead.Account__c,
        'Lead should match account when similarity equals threshold');
    }
    
    @isTest
    static void testNegativeDomainMatchOnly() {
        // Negative: Match only on email domain
        Lead lead =DataFactory.createLead(
            'Test',
            'Different Company', // No company name match
            'test@acmecorp.com' // Exact domain match
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Website = 'www.acmecorp.com' LIMIT 1];
        Assert.areEqual(null, lead.Account__c, 'Lead should not match based on email domain only');
    }

    @isTest
    static void testNegativeNameMatchOnly() {
        // Negative: Match only on company name
        Lead lead =DataFactory.createLead(
            'Test',
            'Company Name Match Only', // Exact name match
            'test@acmecorp.com' // no domain match
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Website = 'www.acmecorp.com' LIMIT 1];
        Assert.areEqual(null, lead.Account__c, 'Lead should not match based on name match only');
    }
    
    @isTest
    static void testNegativeNoMatch() {
        // Negative: No match for company name or domain
        Lead lead =DataFactory.createLead(
            'Test',
            'Unique Company', // No match
            'test@uniquedomain.com' // No match
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual(null, lead.Account__c, 'Lead should not match any account');
    }
    
    @isTest
    static void testFewRecords() {
        // Few records: Process two leads with different matching scenarios
        List<Lead> leads = new List<Lead>();
        leads.add(DataFactory.createLead('Test1','Test Compny Inc','test1@testcompany.com'));
        leads.add(DataFactory.createLead('Test2','Unique Co','test2@uniquedomain.com'));
        insert leads;
        
        leads = [SELECT Account__c FROM Lead WHERE Id IN :leads ORDER BY LastName];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Test Company Inc' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, leads[0].Account__c, 'First lead should match');
        Assert.areEqual(null, leads[1].Account__c, 'Second lead should not match');
    }

    @isTest
    static void testPositiveCallLeadAccountMatchingService() {
        Lead lead = DataFactory.createLead(
            'Test',
            'Acme Corporation',  // Fuzzy match
            'test@acmecorp.com'  // Exact domain match
        ); 
        insert lead;

        // Explicitly call the matching logic
        LeadAccountMatchingService.assignMatchingAccount([SELECT Id, Company, Email, Account__c FROM Lead WHERE Id = :lead.Id]);

        Lead updatedLead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Acme Corp' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, updatedLead.Account__c, 'Lead should match based on exact name and domain');
    }

    @isTest
    static void testPositiveBulkCallLeadAccountMatchingService() {
        // Bulk records: Process 200 leads to test bulk processing
        List<Lead> leads = new List<Lead>();
        leads = DataFactory.createLeads('Flipkart', '@flipkart.com', 200); // Exact domain match and fuzzy name match
        insert leads;
        
        // Explicitly call the matching logic
        LeadAccountMatchingService.assignMatchingAccount([SELECT Id, Company, Email, Account__c FROM Lead WHERE Id IN :leads]);
        // Verify that all leads have been matched
        Integer matchedCount = [SELECT COUNT() FROM Lead WHERE Account__c != null];
        Assert.areEqual(200, matchedCount, 'All 200 leads should match');
    }
    
    @isTest
    static void testBulkPositiveFuzzyRecords() {
        // Bulk records: Process 200 leads to test bulk processing
        List<Lead> leads = new List<Lead>();
        leads = DataFactory.createLeads('Test Company2 Inc', '@testcompany.com', 200); // Exact domain match and fuzzy name match
        insert leads;
        
        Integer matchedCount = [SELECT COUNT() FROM Lead WHERE Account__c != null];
        Assert.areEqual(200, matchedCount, 'All 200 leads should match');
    }

    @isTest
    static void testBulkPositiveExactRecords() {
        // Bulk records: Process 200 leads to test bulk processing
        List<Lead> leads = new List<Lead>();
        leads = DataFactory.createLeads('Acme Corp', '@acmecorp.com', 200); // Exact name and domain match
        insert leads;
        
        Integer matchedCount = [SELECT COUNT() FROM Lead WHERE Account__c != null];
        Assert.areEqual(200, matchedCount, 'All 200 leads should match');
    }

    @isTest
    static void testBulkNegativeRecords() {
        // Bulk records: Process 200 leads to test bulk processing
        List<Lead> leads = new List<Lead>();
        leads = DataFactory.createLeads('World Bank', '@bank.io', 200); // Exact name and domain match
        insert leads;
        
        Integer matchedCount = [SELECT COUNT() FROM Lead WHERE Account__c = null];
        Assert.areEqual(200, matchedCount, 'All 200 leads should not be matched');
    }
    
    @isTest
    static void testCornerCaseNullFields() {
        // Corner case: Lead with null email
        Lead lead =DataFactory.createLead(
            'Test',
            'Test Company', // No match
            null        // No email
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual(null, lead.Account__c, 'Lead with null fields should not match');
    }
    
    @isTest
    static void testCornerCaseSpecialCharacters() {
        // Corner case: Special characters in company name
        Lead lead =DataFactory.createLead(
            'Test',
            'Special Ch@r Co Ltd',       // Special characters in company name
            'test@specialchar.com'       // Exact domain match
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Special Ch@r Co' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, lead.Account__c, 'Lead should match with special characters');
    }
    
    @isTest
    static void testCornerCaseCaseSensitivity() {
        // Corner case: Case sensitivity in company name and email
        Lead lead =DataFactory.createLead(
            'Test',
            'TEST COMPANY INC',           // Uppercase company name
            'TEST@TESTCOMPANY.COM'        // Uppercase email
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Test Company Inc' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, lead.Account__c, 'Lead should match regardless of case');
    }
    
    @isTest
    static void testCornerCasePartialDomain() {
        // Corner case: Partial domain match (should not match)
        Lead lead =DataFactory.createLead(
            'Test',
            'Different Co',                 // No match
            'test@testcompany.co.uk'        // partial domain match
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual(null, lead.Account__c, 'Lead with partial domain should not match');
    }

    @isTest
    static void testMultipleAccountsWithExactMatch() {
        // Create multiple accounts with similar names
        Account exactMatch = DataFactory.createAccount('Genepoint', 'www.genepoint.com');
        Account closeFuzzyMatch = DataFactory.createAccount('Genepoitn', 'www.Genepoint.com');
        Account poorFuzzyMatch = DataFactory.createAccount('Gene Point', 'www.genepoint.com');
        insert new List<Account>{ exactMatch, closeFuzzyMatch, poorFuzzyMatch };

        // Create a lead that should match the exact name
        Lead lead = DataFactory.createLead(
            'LeadExact',
            'Genepoint', // exact match
            'lead1@Genepoint.com'    // matches domain of exactMatch
        );
        insert lead;

        // Validate matches
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Genepoint' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, lead.Account__c, 'Lead should match exact account');
    }

    @isTest
    static void testMultipleAccountsWithFuzzyMatch() {
        // Create multiple accounts with similar names
        List<Account> accounts = new List<Account>();
        accounts.add(DataFactory.createAccount('Genepoitn', 'www.Genepoint.com'));
        accounts.add(DataFactory.createAccount('Gene Point', 'www.genepoint.com'));
        insert accounts;

        // Create a lead that should match the closest fuzzy name
        Lead lead = DataFactory.createLead(
            'LeadFuzzy',
            'Genepoint',         // exact match to closeFuzzyMatch name
            'lead2@genepoint.com'   
        );
        insert lead;

        // Validate matches
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'Gene Point' LIMIT 1];
        Assert.areEqual(matchedAccount.Id, lead.Account__c, 'Lead should match to close account');
    }

    @isTest
    static void testCornerCaseNoWebsite() {
        // Corner case: Match against account with no website
        Lead lead =DataFactory.createLead(
            'Test',
            'No Website Co Ltd',                 // Exact match
            'test@nowebsite.com'                // no domain match
        );
        insert lead;
        
        lead = [SELECT Account__c FROM Lead WHERE Id = :lead.Id];
        Account matchedAccount = [SELECT Id FROM Account WHERE Name = 'No Website Co' LIMIT 1];
        Assert.areEqual(null, lead.Account__c, 'Lead should not match based on fuzzy name when no website');
    }

    @isTest
    static void testNegativeEmptyCallLeadAccountMatchingService() {
        // Bulk records: Process 200 leads to test bulk processing
        List<Lead> leads = new List<Lead>();
        
        // Explicitly call the matching logic
        LeadAccountMatchingService.assignMatchingAccount(leads);
        // Verify that all leads have been matched
        Integer matchedCount = [SELECT COUNT() FROM Lead WHERE Account__c != null];
        Assert.areEqual(0, matchedCount, 'There should be no leads to match');
    }

    @isTest
    static void testSkipExecution() {
        // Set the flag to true so processing is skipped
        LeadAccountMatchingProcessor.doNotExecuteLeadAccountMatchingProcessor = true;
        List<Lead> leads = DataFactory.createLeads('Test Company Inc', '@testcompany.com', 200); // Exact domain match and fuzzy name match
        insert leads;
        
        // Verify that no leads have been matched
        Integer matchedCount = [SELECT COUNT() FROM Lead WHERE Account__c != null];
        Assert.areEqual(0, matchedCount, 'No leads should be matched when execution is skipped');
    }
    
}