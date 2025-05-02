/**
 * @description       : This class is responsible for matching leads to accounts based on their email domains and company names.
 * It uses the Levenshtein distance algorithm to calculate the similarity between company names.
 * The class also handles the normalization of company names by removing noise words and applying synonyms.
 * The matching process is done in bulk to optimize performance and reduce the number of queries.
 * Last modified on  : 05-02-2025
 * Last modified by  : Subramani Kumarasamy
 * Last modified Reason : Initial version created to handle lead and account matching.
 */
public with sharing class LeadAccountMatchingService {

    private static final Map<String, String> SYNONYMS = CustomMetadataTypeUtility.getCompanyNameSynonyms();
    private static final Decimal LEAD_ACCOUNT_MATCH_THRESHOLD = ConstantsUtils.LEAD_ACCOUNT_MATCH_THRESHOLD;
    private static final String NOISE_WORDS = ConstantsUtils.NOISE_WORDS;
    
    /**
     * @description       : This method assigns accounts to leads based on matching domains
     * @param newLeads    : List of new leads to be processed
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     */
    public static void assignMatchingAccount( List<Lead> newLeads) {

        if (newLeads == null || newLeads.isEmpty()){
            return; // No leads to process
        }

        Map<String, List<Lead>> domainToLeads = groupLeadsByDomain(newLeads);

        if (domainToLeads.keySet().isEmpty()){
            return;
        }

        // Retrieve the list of matching accounts
        Map<String, List<Account>> domainToAccounts = retrieveMatchingAccounts(domainToLeads.keySet());

        // Process leads and assign matched AccountId
        assignAccountsToLeads(domainToLeads, domainToAccounts);
    }

    /**
     * @description       : This method assigns accounts to leads based on matching domains
     * @param domainToLeads : Map of domains to leads
     * @param domainToAccounts : Map of domains to accounts
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     */
    private static void assignAccountsToLeads(Map<String, List<Lead>> domainToLeads, Map<String, List<Account>> domainToAccounts) {
        for (String domain : domainToLeads.keySet()) {
            List<Account> possibleAccounts = domainToAccounts.get(domain);
            if (possibleAccounts == null || possibleAccounts.isEmpty()){
                continue; // No matching accounts for this domain
            }
    
            for (Lead lead : domainToLeads.get(domain)) {
                Account match = matchLeadToAccount(lead, possibleAccounts);
                if (match != null) {
                    lead.Account__c = match.Id;
                }
            }
        }
    }

    /**
     * @description       : This method groups leads by their email domain
     * @param leads       : List of leads to be grouped
     * @return Map<String, List<Lead>> : A map where the key is the domain and the value is a list of leads
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     */
    private static Map<String, List<Lead>> groupLeadsByDomain(List<Lead> leads) {
        Map<String, List<Lead>> domainMap = new Map<String, List<Lead>>();
    
        for (Lead lead : leads) {
            if (String.isNotBlank(lead.Email) && String.isNotBlank(lead.Company) && lead.Account__c == null) {
                String domain = extractDomainFromEmail(lead.Email);
                if (String.isNotBlank(domain)) {
                    if (!domainMap.containsKey(domain)) {
                        domainMap.put(domain, new List<Lead>());
                    }
                    domainMap.get(domain).add(lead);
                }
            }
        }
    
        return domainMap;
    }
    /**
     * @description       : This method retrieves accounts with matching domains
     * @param emailDomains : Set of email domains to match
     * @return Map<String, List<Account>> : A map where the key is the domain and the value is a list of accounts
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     */
    private static Map<String, List<Account>> retrieveMatchingAccounts(Set<String> emailDomains) {
        Map<String, List<Account>> domainToAccounts = new Map<String, List<Account>>();
        
        //Query accounts with matching domains
        if (Schema.sObjectType.Account.isAccessible()) {
            for (Account acc : [SELECT Id, Name, WebsiteDomain_c__c FROM Account WHERE WebsiteDomain_c__c != NULL AND (WebsiteDomain_c__c IN :emailDomains) LIMIT 1000]){
                String domain = acc.WebsiteDomain_c__c.toLowerCase();
                if (!String.isBlank(domain)) {
                    if (!domainToAccounts.containsKey(domain)) {
                        domainToAccounts.put(domain, new List<Account>());
                    }
                    domainToAccounts.get(domain).add(acc);
                }
            }
        }
        return domainToAccounts;
    }

    /**
     * @description       : This method matches a lead to the best possible account based on company name similarity
     * @param lead        : The lead to be matched
     * @param possibleAccounts : List of possible accounts to match against
     * @return Account    : The best matching account or null if no match is found
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     */
    private static Account matchLeadToAccount(Lead lead, List<Account> possibleAccounts) {
        Account bestAccount = null;
        Decimal bestScore = 0;
        String normalizedLeadCompanyName = normalizeCompanyName(lead.Company);
        
        for (Account acc : possibleAccounts) {
            String normalizedAccName = normalizeCompanyName(acc.Name);
            if(normalizedLeadCompanyName == normalizedAccName) {
                return acc; // Exact match found
            }

            Decimal totalSimilarity = levenshteinSimilarity(normalizedLeadCompanyName, normalizedAccName);
            
            if (totalSimilarity > bestScore) {
                bestScore = totalSimilarity;
                bestAccount = acc;
            }
        }
        return (bestScore >= LEAD_ACCOUNT_MATCH_THRESHOLD) ? bestAccount : null;
    }
    
    /**
     * @description       : This method extracts the domain from an email address
     * @param email       : The email address to extract the domain from
     * @return String     : The extracted domain or an empty string if not found
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     */
    private static String extractDomainFromEmail(String email) {
        Integer atIndex = email.indexOf('@');
        return (atIndex == -1) ? '' : email.substring(atIndex + 1).toLowerCase();
    }

    /**
     * @description       : This method normalizes a company name by removing noise words and applying synonyms
     * @param name        : The company name to be normalized
     * @return String     : The normalized company name
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     */
    public static String normalizeCompanyName(String name) {
        name = name.toLowerCase().replaceAll('[^a-z0-9 ]', '').trim();
        List<String> words = name.split('\\s+');
        Set<String> noiseWords = new Set<String>(NOISE_WORDS.split(','));
        List<String> cleanWords = new List<String>();

        for (String word : words) {
            if (!noiseWords.contains(word)) {
                cleanWords.add(word);
            }
            if (SYNONYMS.containsKey(word)) {
                word = SYNONYMS.get(word);
            }
        }
        return String.join(cleanWords, ' ');
    }

    /**
     * @description       : This method calculates the Levenshtein similarity between two strings
     * @param leadCompanyName : The first string
     * @param accountName      : The second string
     * @return Decimal       : The similarity score as a percentage
     * @last modified on  : 05-02-2025
     * @last modified by  : Subramani Kumarasamy
     */
    public static Decimal levenshteinSimilarity(String leadCompanyName, String accountName) {
        Integer dist = accountName.getLevenshteinDistance(leadCompanyName);
        Integer maxLen = Math.max(leadCompanyName.length(), accountName.length());
        return maxLen == 0 ? 100 : ((Decimal.valueOf(maxLen - dist) / maxLen) * 100);
    }

}