public with sharing class OpportunityService {
    
    public static List<Account> createAccount(Map<Id,Decimal> accountIdToAmountMap) {
        List<Account> accounts = new List<Account>();
        for(Id accountId : accountIdToAmountMap.keyset()){
            Account account = new Account();
            account.Id = accountId;
            account.Recent_Opportunity_Amount__c = accountIdToAmountMap.get(accountId);
            accounts.add(account);
        }

        return !accounts.isEmpty() ? accounts : NULL;
    }
}