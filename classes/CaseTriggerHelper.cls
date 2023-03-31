public with sharing class CaseTriggerHelper {

  public static void beforeInsert(List<Case> newList) {//NOPMD
        
    }

    public static void afterInsert(List<Case> newList){
        populateLatestCaseNumber(newList);
    }

    public static void beforeUpdate(List<Case> newList,Map<Id,Case> oldMap){//NOPMD
        
    }

    public static void afterUpdate(List<Case> newList,Map<Id,Case> oldMap){//NOPMD
        
    }

    public static void beforeDelete(List<Case> oldList){//NOPMD
        
    }

    public static void afterDelete(List<Case> oldList){//NOPMD
        
    }
    
    private static void populateLatestCaseNumber(List<Case> cases) {
        Map<Id,String> accountIdToCaseNumberMap = new Map<Id,String>();
        for(Case newCase : cases){
            if(newCase.AccountId != NULL){
                accountIdToCaseNumberMap.put(newCase.accountId,newCase.CaseNumber);
            }
        }

        if(!accountIdToCaseNumberMap.isEmpty()){
            List<Account> accounts = CaseService.createAccount(accountIdToCaseNumberMap);
            if(!accounts.isEmpty()){
                update accounts;
            }
        }
    }
}