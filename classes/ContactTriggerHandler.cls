public with sharing class ContactTriggerHandler {
    
    public static void beforeInsert(List<Contact> newList) {
        preventContactOnDuplicateEmail(newList);
    }
         
    public static void afterInsert(List<Contact> newList) { //NOPMD(BlankMethod)
        emailUponCreation(newList);
    }
         
    public static void beforeUpdate(List<Contact> newList, Map<Id, Contact> oldMap) { //NOPMD(BlankMethod)
    }
         
    public static void afterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) { //NOPMD(BlankMethod)
    } 
        
    public static void beforeDelete(List<Contact> oldList) { //NOPMD(BlankMethod)
    }
         
    public static void afterDelete(List<Contact> oldList) { //NOPMD(BlankMethod)
    }

    public static void emailUponCreation(List<Contact> newContacts) { //Q21
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for (Contact contact : newContacts) {
            if (contact.Email != null && contact.Email != '') {
                // Create email message with template
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{contact.Email});
                emailList.add(email);
            }
        }
        // Send email
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }

    private static void preventContactOnDuplicateEmail(List<Contact> contacts) { //Q30
        Set<String> contactEmails = new Set<String>();
        List<Contact> allContacts = [SELECT Id, Email FROM Contact];
        for (Contact contact : allContacts) {
            if (contact.Email != NULL) {
                contactEmails.add(contact.Email);
            }
        }
        for (Contact contact : contacts) {
            if (contactEmails.contains(contact.Email)) {
                contact.addError('This email is exist in another contact you can not create contact with this email');
            }
        }
    }
}