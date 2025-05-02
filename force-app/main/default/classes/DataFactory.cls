/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : Subramani Kumarasamy
**/
@isTest
public class DataFactory {

    // Method to create accounts for testing
    public static List<Account> createAccounts(Integer numberOfAccounts) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            Account acc = new Account(
                Name = 'Company ' + i,
                Website = 'company' + i + '.com'
            );
            accounts.add(acc);
        }
        return accounts;
    }

    // Method to create accounts with specific names for testing
    public static Account createAccount(String accName, String website) {
        Account acc = new Account(
            Name = accName,
            Website = website
        );
        return acc;
    }

    // Method to create leads for testing
    public static List<Lead> createLeads(String companyName, String emailDomain, Integer numberOfLeads) {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < numberOfLeads; i++) {
            Lead lead = new Lead(
                LastName = 'Test' + i,
                Company = companyName,
                Email = 'test' + i + emailDomain
            );
            leads.add(lead);
        }
        return leads;
    }

    // Method to create a lead with specific details for testing
    public static Lead createLead(String lastName, String company, String email) {
        Lead lead = new Lead(
            LastName = lastName,
            Company = company,
            Email = email
        );
        return lead;
    }
}