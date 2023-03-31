public with sharing class AccountTriggerHandler {
  public static void beforeInsert(List<Account> newList) {
        updateRating(newList);
        copyBillingAddressToShippingAddress(newList);
    }

    public static void afterInsert(List<Account> newList){
        createRelatedContact(newList);
        createRelatedRecordBasedOnChoice(newList);
        createRelatedOpportunity(newList);
        shareWithStandardUsers(newList);
    }

    public static void beforeUpdate(List<Account> newList,Map<Id,Account> oldMap){//NOPMD
        populateDescription(newList, oldMap);
        copyBillingAddressToShippingAddress(newList);
        updateRatingForMedia(newList, oldMap);
        //stopAccountUpdate(newList, oldMap);
    }

    public static void afterUpdate(List<Account> newList, Map<Id,Account> oldMap){//NOPMD
        updateContactPhone(newList, oldMap);
        updateContactPhones(newList, oldMap);
        handleAccountUpdate(newList, oldMap);
        updatingContactMailingAddress(newList, oldMap);
        copyBillingToShippingAddressWithQuery(newList, oldMap);
        handleAccountOwnerChange(newList, oldMap);
        getAccountRelatedOpportunity(newList, oldMap);
    }

    public static void beforeDelete(List<Account> oldList){//NOPMD
        handleAccountDelete(oldList);
        restrictDelete(oldList);
        restrictAccountDeleteIfOpportunutyExist(oldList);
        restrictAccountDeleteIfCaseExist(oldList);
    }
     
    public static void afterDelete(List<Account> oldList){//NOPMD
    }
    
    
    public static void updateRating(List<Account> accounts) {
        for(Account account : accounts) {
            if(account.Industry != NULL && account.Industry == 'Media'){
                account.Rating = 'Hot';
            }
        }
    }

    private static void copyBillingAddressToShippingAddress(List<Account> accounts) {
        for(Account account : accounts) {
            if(account.Copy_to_Shipping__c){
                if(account.BillingCity != NULL){
                    account.ShippingCity = account.BillingCity;
                }
                if(account.BillingCountry != NULL){
                    account.ShippingCountry = account.BillingCountry;
                }
                if(account.BillingStreet != NULL){
                    account.ShippingStreet = account.BillingStreet;
                }
                if(account.BillingPostalCode != NULL){
                    account.ShippingPostalCode = account.BillingPostalCode;
                }
                if(account.BillingState != NULL){
                    account.ShippingState = account.BillingState;
                }
            }
        }
    }
    
    private static void createRelatedContact(List<Account> accounts) {
        List<Contact> contacts = AccountService.createContact(accounts);
            if(!contacts.isEmpty()) {
                insert contacts;
            }
    }

    private static void createRelatedRecordBasedOnChoice(List<Account> accounts) {
        for(Account account : accounts) {
            if(account.Contact__c){
                List<Contact> contacts = AccountService.createContact(accounts);
                if(!contacts.isEmpty()) {
                    insert contacts;
                }
            }
            if(account.Opportunity__c && account.Active__c == 'Yes'){
                List<Opportunity> opportunities = AccountService.createOpportunity(accounts);
                if(!opportunities.isEmpty()) {
                    insert opportunities;
                }
            }
        }
    }

    private static void createRelatedOpportunity(List<Account> accounts) {
        for(Account account : accounts) {
            List<Opportunity> opportunities = AccountService.createOpportunity(accounts);
            if(!opportunities.isEmpty()) {
                insert opportunities;
            }
        }
    }

    private static void populateDescription(List<Account> accounts, Map<Id,Account> accountMap) {
        for(Account account : accounts) {
            if(account.Phone != accountMap.get(account.Id).Phone) {
                account.Description = 'Phone is Updated! Old Value : ' + accountMap.get(account.Id).Phone + ' & New Value : ' + account.Phone;
            }
        }
    }
    private static void updateRatingForMedia(List<Account> accounts, Map<Id, Account> accountMap){ //Q1
        for(Account account : accounts){
            if(accountMap.containskey(account.Id) && account.Industry != accountMap.get(account.Id).Industry){
                if(account.Industry != NULL && account.Industry == 'Media'){
                    account.Rating = 'Hot';
                }
            }
        }
    }

    public static void updateContactPhone(List<Account> account, Map<Id, Account> updatedAccounts) { //Q3
        Set<Id> accountIds = updatedAccounts.keySet();
        
        // Query for all related Contacts to the updated Accounts
        List<Contact> relatedContacts = [SELECT Id, AccountId, HomePhone FROM Contact WHERE AccountId IN :accountIds];
        
        // Create a map to store the updated Home Phone values by Contact Id
        Map<Id, String> updatedContactPhones = new Map<Id, String>();
        
        // Loop through each related Contact and update its Home Phone value
        for (Contact contact : relatedContacts) {
            String updatedPhone = updatedAccounts.get(contact.AccountId).Phone;
            
            if (updatedPhone != null) {
                updatedContactPhones.put(contact.Id, updatedPhone);
            }
        }
        
        // Update the Home Phone fields on all related Contacts
        if (!updatedContactPhones.isEmpty()) {
            List<Contact> contactsToUpdate = new List<Contact>();
            
            for (Contact contact : [SELECT Id, HomePhone FROM Contact WHERE Id IN :updatedContactPhones.keySet()]) {
                contact.HomePhone = updatedContactPhones.get(contact.Id);
                contactsToUpdate.add(contact);
            }
            
            update contactsToUpdate;
        }  
    }

    public static void updateContactPhones(List<Account> updatedAccounts, Map<Id, Account> updateAccounts) { //Q4
        Set<Id> accountIds = new Set<Id>();
        
        // Add all updated Account Ids to the set
        for (Account account : updatedAccounts) {
            accountIds.add(account.Id);
        }
        
        // Query for all related Contacts to the updated Accounts
        List<Contact> relatedContacts = [SELECT Id, AccountId, HomePhone FROM Contact WHERE AccountId IN :accountIds];
        
        // Create a map to store the updated Home Phone values by Contact Id
        Map<Id, String> updatedContactPhones = new Map<Id, String>();
        
        // Loop through each related Contact and update its Home Phone value
        for (Contact contact : relatedContacts) {
            String updatedPhone = null;
            
            // Check if the updated Account Id matches the Contact's Account Id
            if (updatedAccounts != null && updatedAccounts.size() > 0 && contact.AccountId != null && updatedAccounts[0].Id == contact.AccountId) {
                updatedPhone = updatedAccounts[0].Phone;
            } else {
                // Query for the updated Account record and get its Phone value
                updatedPhone = [SELECT Phone FROM Account WHERE Id = :contact.AccountId LIMIT 1].Phone;
            }
            
            if (updatedPhone != null) {
                updatedContactPhones.put(contact.Id, updatedPhone);
            }
        }
        
        // Update the Home Phone fields on all related Contacts
        if (!updatedContactPhones.isEmpty()) {
            List<Contact> contactsToUpdate = new List<Contact>();
            
            for (Id contactId : updatedContactPhones.keySet()) {
                contactsToUpdate.add(new Contact(Id = contactId, HomePhone = updatedContactPhones.get(contactId)));
            }
            
            update contactsToUpdate;
        }
    }

    public static void handleAccountUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) { //Q8
        Set<Id> accountIdsToUpdate = new Set<Id>();
        for (Account newAccount : newAccounts) {
            Account oldAccount = oldAccountMap.get(newAccount.Id);
            if (newAccount.Active__c == 'No' && oldAccount.Active__c == 'Yes') {
                accountIdsToUpdate.add(newAccount.Id);
            }
        }
        if (!accountIdsToUpdate.isEmpty()) {
            List<Opportunity> opportunitiesToUpdate = [SELECT Id, StageName FROM Opportunity WHERE AccountId IN :accountIdsToUpdate AND StageName != 'Closed Won'];
            for (Opportunity opp : opportunitiesToUpdate) {
                opp.StageName = 'Closed Lost';
            }
            if (!opportunitiesToUpdate.isEmpty()) {
                
                update opportunitiesToUpdate;
            }
        }
    }

    public static void handleAccountDelete(List<Account> accountsToDelete) { //Q9
        for (Account account : accountsToDelete) {
            if (account.Active__c == 'Yes') {
                account.addError('Accounts cannot be deleted if Active is Yes.');
            }
        }
    }

    public static void stopAccountUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) { //Q10
        for (Account newAccount : newAccounts) {
            Account oldAccount = oldAccountMap.get(newAccount.Id);
            if (newAccount.CreatedDate > System.today().addDays(-7)) {
                newAccount.addError('Accounts cannot be edited if they were created more than 7 days ago.');
            }
        }
    }

    private static void restrictDelete(List<Account> accounts) { //Q13
        Id profileId = userinfo.getProfileId();
        Id systemAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        for(Account account : accounts) {
            if(profileId != systemAdminId ) {
                account.addError('You Don\'t have permission to delete this account,'+ 
                                +'Please contact SYstem Admin ');
            }
        }
    }

    public static void restrictAccountDeleteIfOpportunutyExist(List<Account> accounts) { //Q15
        List<Opportunity> opportunities = [SELECT AccountId FROM Opportunity ];
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opportunity : opportunities) {
            accountIds.add(opportunity.AccountId);
        }
        for(Account account : accounts) {
            if(accountIds.contains(account.Id)) {
                account.addError('Opportunity Exists');
            }
        }
    }

    public static void restrictAccountDeleteIfCaseExist(List<Account> accounts) { //Q16
        List<Case> cases = [SELECT AccountId FROM Case ];
        Set<Id> accountIds = new Set<Id>();
        for(Case caseRecord : cases) {
            accountIds.add(caseRecord.AccountId);
        }
        for(Account account : accounts) {
            if(accountIds.contains(account.Id)) {
                account.addError('Case Exists');
            }
        }
    }

    public static void updatingContactMailingAddress(List<Account> accounts, Map<Id, Account> accountMap){  // Q5 //NOPMD
        Map<Id, Account> newAccountMap = new Map<Id, Account>(accounts);
        List<Contact> contacts = [SELECT Id, AccountId, HomePhone, MailingCity, MailingCountry, MailingGeocodeAccuracy, MailingLatitude, MailingPostalCode, MailingState, MailingStreet FROM Contact WHERE AccountId IN:newAccountMap.keySet()];   //NOPMD
        for (Contact contact : contacts) {
            Account account = accountMap.get(contact.AccountId);
            Account newAccount = newAccountMap.get(contact.AccountId);
            if(newAccount.Phone != account.Phone){
                contact.HomePhone = newAccount.Phone;
            }
            if(newAccount.BillingCity != NULL && newAccount.BillingCity != account.BillingCity) {
                contact.MailingCity = newAccount.BillingCity;
            }
            if(newAccount.BillingCountry != NULL && newAccount.BillingCountry != account.BillingCountry) {
                contact.MailingCountry = newAccount.BillingCountry;
            }
            if(newAccount.BillingGeocodeAccuracy != NULL && newAccount.BillingGeocodeAccuracy != account.BillingGeocodeAccuracy) {
                contact.MailingGeocodeAccuracy = newAccount.BillingGeocodeAccuracy;
            }
            if(newAccount.BillingLatitude != NULL && newAccount.BillingAddress != account.BillingAddress) {
                contact.MailingLatitude = newAccount.BillingLatitude;
            }
            if(newAccount.BillingPostalCode != NULL && newAccount.BillingPostalCode != account.BillingPostalCode) {
                contact.MailingPostalCode = newAccount.BillingPostalCode;
            }
            if(newAccount.BillingState != NULL && newAccount.BillingState != account.BillingState) {
                contact.MailingState = newAccount.BillingState;
            }
            if(newAccount.BillingStreet != NULL && newAccount.BillingStreet != account.BillingStreet) {
                contact.MailingStreet = newAccount.BillingStreet;
            }
        }
        update contacts;   //NOPMD
    }

    private static void copyBillingToShippingAddressWithQuery(List<Account> accounts, Map<Id, Account> accountMap){  //Q6       //NOPMD
        List<Account> AccountsWithContacts = [SELECT Id, BillingStreet, BillingState, BillingPostalCode, BillingAddress, BillingGeocodeAccuracy, BillingCountry, BillingCity, BillingLatitude, ( SELECT Id, AccountId, MailingCity, MailingCountry, MailingGeocodeAccuracy, MailingLatitude, MailingPostalCode, MailingState, MailingStreet FROM Contacts ) FROM Account WHERE Id IN: accountMap.keySet()];     //NOPMD
        List<Contact> contacts = new List<Contact>();
        for (Account account : AccountsWithContacts) {
            Account oldAccount = accountMap.get(account.Id);
            for (Contact contact : account.contacts) {
                if(account.BillingCity != NULL && account.BillingCity != oldAccount.BillingCity) {
                    contact.MailingCity = account.BillingCity;
                }
                if(account.BillingCountry != NULL && account.BillingCountry != oldAccount.BillingCountry) {
                    contact.MailingCountry = account.BillingCountry;
                }
                if(account.BillingGeocodeAccuracy != NULL && account.BillingGeocodeAccuracy != oldAccount.BillingGeocodeAccuracy) {
                    contact.MailingGeocodeAccuracy = account.BillingGeocodeAccuracy;
                }
                if(account.BillingLatitude != NULL && account.BillingAddress != oldAccount.BillingAddress) {
                    contact.MailingLatitude = account.BillingLatitude;
                }
                if(account.BillingPostalCode != NULL && account.BillingPostalCode != oldAccount.BillingPostalCode) {
                    contact.MailingPostalCode = account.BillingPostalCode;
                }
                if(account.BillingState != NULL && account.BillingState != oldAccount.BillingState) {
                    contact.MailingState = account.BillingState;
                }
                if(account.BillingStreet != NULL && account.BillingStreet != oldAccount.BillingStreet) {
                    contact.MailingStreet = account.BillingStreet;
                }
                contacts.add(contact);
            }
        }
        update contacts;         //NOPMD
    }

    public static void handleAccountOwnerChange(List<Account> updatedAccounts, Map<Id, Account> oldAccountMap) { //Q27 28
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Account updatedAccount : updatedAccounts) {
            Account oldAccount = oldAccountMap.get(updatedAccount.Id);
            
            if (updatedAccount.OwnerId != oldAccount.OwnerId) {
                contactsToUpdate.addAll([SELECT Id, OwnerId FROM Contact WHERE AccountId = :updatedAccount.Id]);
            }
        }
        
        if (!contactsToUpdate.isEmpty()) {
            for (Contact contactToUpdate : contactsToUpdate) {
                contactToUpdate.OwnerId = updatedAccounts[0].OwnerId;
            }
            
            update contactsToUpdate;
        }
    }

    public static void getAccountRelatedOpportunity(List<Account> accounts, Map<Id,Account> accountMap) { //Q23
        List<Opportunity> opportunities = [SELECT Id, StageName, Annual_Revenue__c, Account.AnnualRevenue, AccountId, Account.Active__c FROM Opportunity WHERE AccountId IN: accountMap.keySet()];
        
        for (Opportunity opportunity : opportunities) {
            if (opportunity.Account.Active__c != accountMap.get(opportunity.AccountId).Active__c 
                && opportunity.Account.Active__c == 'no' 
                && accountMap.get(opportunity.AccountId).Active__c == 'yes' 
                && opportunity.StageName != 'Closed Won') {
                opportunity.StageName = 'Close Lost';
            }
            if (opportunity.Account.AnnualRevenue != NULL && opportunity.Account.AnnualRevenue !=  accountMap.get(opportunity.AccountId).AnnualRevenue) {
                opportunity.Annual_Revenue__c = opportunity.Account.AnnualRevenue;
            }
        }
        
        update opportunities;
    }

    public static void shareWithStandardUsers(List<Account> newAccounts) { //Q31
        List<AccountShare> accountSharesToInsert = new List<AccountShare>();
        List<User> standardUsers = [SELECT Id FROM User WHERE Profile.Name = 'Standard User'];
        
        for (Account newAccount : newAccounts) {
            for (User standardUser : standardUsers) {
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = newAccount.Id;
                accountShare.UserOrGroupId = standardUser.Id;
                accountShare.AccountAccessLevel = 'Read';
                accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                accountSharesToInsert.add(accountShare);
            }
        }
        
        insert accountSharesToInsert;
    }

}