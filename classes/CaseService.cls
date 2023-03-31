public with sharing class CaseService {
    
    public static List<Account> createAccount(Map<Id,String> accountIdToCaseNumberMap) {
        List<Account> accounts = new List<Account>();
        for(Id accountId : accountIdToCaseNumberMap.keyset()){
            Account account = new Account();
            account.Id = accountId;
            account.Latest_Case_Number__c = accountIdToCaseNumberMap.get(accountId);
            accounts.add(account);
        }

        return !accounts.isEmpty() ? accounts : NULL;
    }
}