public with sharing class AccountService {
    
    public static List<Contact> createContact(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
        for(Account account : accounts) {
            Contact contact = new Contact();
            contact.LastName = account.Name;
            contact.AccountId = account.Id;
            contacts.add(contact);
        }

        return !contacts.isEmpty() ? contacts : NULL;
    }

    public static List<Opportunity> createOpportunity(List<Account> accounts) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for(Account account : accounts) {
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.Name = account.Name;
            newOpportunity.StageName = 'Qualification';
            newOpportunity.CloseDate = System.today();
            newOpportunity.AccountId = account.Id;
            opportunities.add(newOpportunity);
        }

        return !opportunities.isEmpty() ? opportunities : NULL;
    }
}