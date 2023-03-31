public with sharing class CaseTriggerHandler { 
    
    public static void beforeInsert(List<Case> newList) { //NOPMD(BlankMethod)
     }
     
     public static void afterInsert(List<Case> newList) { 
       updateLatestCaseNumber(newList);
       populateNumberOfCaseOnAccount(newList);
     }
     
     public static void beforeUpdate(List<Case> newList, Map<Id, Case> oldMap) { //NOPMD(BlankMethod)
     }
     
     public static void afterUpdate(List<Case> newList, Map<Id, Case> oldMap) { //NOPMD(BlankMethod)
     }
    
     public static void beforeDelete(List<Case> oldList) { //NOPMD(BlankMethod)
     }
     
     public static void afterDelete(List<Case> oldList) { //NOPMD(BlankMethod)
     }

     private static void updateLatestCaseNumber(List<Case> newCases) {
        Set<Id> accountIdsToUpdate = new Set<Id>();
        Map<Id, Case> latestCasesByAccount = new Map<Id, Case>();
        for (Case caseRecord : newCases) {
            if (caseRecord.AccountId != NULL) {
                accountIdsToUpdate.add(caseRecord.AccountId);
                if (!latestCasesByAccount.containsKey(caseRecord.AccountId) || caseRecord.CreatedDate > latestCasesByAccount.get(caseRecord.AccountId).CreatedDate) {
                    latestCasesByAccount.put(caseRecord.AccountId, caseRecord);
                }
            }
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountIdsToUpdate) {
            Account account = new Account(Id=accountId);
            account.Latest_Case_Number__c = latestCasesByAccount.get(accountId).CaseNumber;
            accountsToUpdate.add(account);
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate; //NOPMD
        }
    }

    private static void populateNumberOfCaseOnAccount(List<Case> cases) { //Q22
        RecordType partnerRecordId = [Select ID,Name from RecordType where Name = 'Partner Case'];
        RecordType customerRecordId = [Select ID,Name from RecordType where Name = 'Customer Case'];
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<Id> partnerAccountIds = new Set<Id>();
        Set<Id> customerAccountIds = new Set<Id>();
        for (Case c : cases) {
            if (partnerRecordId.Id == c.RecordTypeId) {
                partnerAccountIds.add(c.AccountId);
            } else if (customerRecordId.Id == c.RecordTypeId) {
                customerAccountIds.add(c.AccountId);
            }
        }
        List<Account> partnerAccountsToUpdate = [SELECT Id, Total_Partner_Cases__c FROM Account WHERE Id IN :partnerAccountIds];
        for (Account account : partnerAccountsToUpdate) {
            if(account.Total_Partner_Cases__c == null) {
                account.Total_Partner_Cases__c = 1;
            }
            else {
                account.Total_Partner_Cases__c = account.Total_Partner_Cases__c + 1;
            }
            accountMap.put(account.Id, account);
        }
        List<Account> customerAccountsToUpdate = [SELECT Id, Totak_Coustmer_Cases__c FROM Account WHERE Id IN :customerAccountIds];
        for (Account account : customerAccountsToUpdate) {
            if(account.Totak_Coustmer_Cases__c == null) {
                account.Totak_Coustmer_Cases__c = 1;
            }
            else {
                account.Totak_Coustmer_Cases__c = account.Totak_Coustmer_Cases__c + 1;
            }
            accountMap.put(account.Id, account);
        }
        update accountMap.values();
    } 
}