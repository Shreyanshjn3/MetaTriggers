public with sharing class OpportunityTriggerHandler {
    
  public static void beforeInsert(List<Opportunity> newList) {//NOPMD
        populateDescription(newList);
        showUpdateStage(newList);
        updateRelatedAccounts(newList);
    }
    
    public static void afterInsert(List<Opportunity> newList){
        latestOpportunityAmount(newList);
    }

    public static void beforeUpdate(List<Opportunity> newList,Map<Id,Opportunity> oldMap){//NOPMD
        populateClosedLostReason(newList, oldMap);
    }

    public static void afterUpdate(List<Opportunity> newList,Map<Id,Opportunity> oldMap){//NOPMD
        opportunityStageTaskReacord(newList, oldMap);
        updateRelatedAccounts(newList, oldMap);
        updateDescriptionClosedLostAndWon(newList, oldMap);
    }

    public static void beforeDelete(List<Opportunity> oldList){//NOPMD
        restrictOpportunityDelete(oldList);
    }

    public static void afterDelete(List<Opportunity> oldList){//NOPMD
        updateRelatedAccounts(oldList);
    }
    

    private static void populateDescription(List<Opportunity> opportunities){
        for(Opportunity opportunityItem : opportunities){
            if(opportunityItem.Amount != NULL && opportunityItem.Amount > 100000){
                opportunityItem.Description = 'Hot Opportunity';
            }
        }
    }

    private static void latestOpportunityAmount(List<Opportunity> opportunities) {
        Map<Id,Decimal> accountIdToAmountMap = new Map<Id,Decimal>();
        for(Opportunity opportunityItem : opportunities){
            if(opportunityItem.AccountId != NULL){
                accountIdToAmountMap.put(opportunityItem.accountId,opportunityItem.Amount);
            }
        }

        if(!accountIdToAmountMap.isEmpty()){
            List<Account> accounts = OpportunityService.createAccount(accountIdToAmountMap);
            if(!accounts.isEmpty()){
                update accounts;
            }
        }
    }

    private static void showUpdateStage(List<Opportunity> opportunities){ //Q2
        for (Opportunity opportunity : opportunities) {
            if(opportunity.StageName == 'Closed Won'){
                opportunity.Description = 'Opp is Closed Won';
            }
            else if(opportunity.StageName == 'Closed Lost'){
                opportunity.Description = 'Opp is Closed Lost';
            }
            if(opportunity.StageName == 'Closed Won'){
                opportunity.Description = 'Opp is Open';
            }
        }
    }

    private static void populateClosedLostReason(List<Opportunity> opportunities, Map<Id, Opportunity> opportunityMap) { //Q12
        for(Opportunity opportunity : opportunities) {
            if((opportunity.StageName == 'Closed Lost' 
            && opportunityMap.get(opportunity.id).StageName != 'Closed Lost'
            && opportunity.Closed_Lost_Reason__c == opportunityMap.get(opportunity.id).Closed_Lost_Reason__c)) {
                opportunity.Closed_Lost_Reason__c.addError('Please populate Closed Lost Reason');
            }
        }
    }

    private static void restrictOpportunityDelete(List<Opportunity> opportunities) { //Q14
        Id profileId = userinfo.getProfileId();
        Id systemAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        for(Opportunity opportunity : opportunities) {
            if(profileId != systemAdminId ) {
                opportunity.addError('You Don\'t have permission to delete this opportunity,'+ 
                                +'Please contact SYstem Admin ');
            }
        }
    }

    private static void opportunityStageTaskReacord(List<Opportunity> opportunities, Map<Id, Opportunity> opportunityMap){ //Q7
        List<Task> newTasks = new List<Task>();
        for (Integer i = 0; i < opportunities.size()-1; i++) {
            Task newTask = new Task();
            newTask.OwnerId = UserInfo.getUserId();
            newTask.status = 'The Stage';
            newTask.priority = 'High';
            newTasks.add(newTask);
        }
        insert newTasks;
    }

    private static void updateRelatedAccounts(List<Opportunity> opportunities) { //Q23
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            accountIds.add(opportunity.AccountId);
        }
        List<Account> accounts = UpdateOpportunityRelatedAccounts(accountIds);
        if (!accounts.isEmpty()) {
            update accounts;
        }
    }

    private static void updateRelatedAccounts(List<Opportunity> opportunities, Map<Id, Opportunity> opportunityMap) { //Q23
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            if (opportunity.Amount != opportunityMap.get(opportunity.Id).Amount) {
                accountIds.add(opportunity.AccountId);
            }
        }
        List<Account> accounts = UpdateOpportunityRelatedAccounts(accountIds);
        if (!accounts.isEmpty()) {
            update accounts;
        }
    }

    public static List<Account> updateOpportunityRelatedAccounts(Set<Id> AccountIds) { //Q23
        List<Account> accounts = new List<Account>();
        AggregateResult[] groupedResults = [SELECT AccountId, Sum(Amount)annulRevenue FROM Opportunity  WHERE AccountId IN: AccountIds GROUP BY AccountId];

        for (AggregateResult variable : groupedResults) {
            String accountId = String.valueOf(variable.get('AccountId'));
            Integer annualRevenue = Integer.valueOf(variable.get('annulRevenue'));
            accounts.add(new Account(Id = accountId, AnnualRevenue = annualRevenue));
        }

        return accounts;
    }

    public static void updateDescriptionClosedLostAndWon(List<Opportunity> updatedOpportunities, Map<Id, Opportunity> opportunityMap) { //Q26
        for (Opportunity opp : updatedOpportunities) {
            if (opp.StageName != opportunityMap.get(opp.Id).StageName) {
                if (opp.StageName == 'Closed Won') {
                    opp.Description = 'Opportunity is Closed Won';
                } else if (opp.StageName == 'Closed Lost') {
                    opp.Description = 'Opportunity is Closed Lost';
                }
            }
        }
        update updatedOpportunities;
    }

}