public with sharing class ContactService {
    
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
}