public with sharing class PositionTriggerHandler {
    
    public static void beforeInsert(List<Position__c> newList) {
        populateDefaultValue(newList);
    }
     
    public static void afterInsert(List<Position__c> newList) { //NOPMD(BlankMethod)
    }
     
    public static void beforeUpdate(List<Position__c> newList, Map<Id, Position__c> oldMap) { //NOPMD(BlankMethod)
    }
     
    public static void afterUpdate(List<Position__c> newList, Map<Id, Position__c> oldMap) { //NOPMD(BlankMethod)
    } 
    
    public static void beforeDelete(List<Position__c> oldList) { //NOPMD(BlankMethod)
    }
     
    public static void afterDelete(List<Position__c> oldList) { //NOPMD(BlankMethod)
    }

    private static void populateDefaultValue(List<Position__c> Positions) {
        for(Position__c position : Positions) {
            if(position.Open_Date__c == NULL && position.Minimum_Pay__c == NULL && position.Maximum_Pay__c == NULL) {
                position.Open_Date__c = System.Today();
                position.Minimum_Pay__c = 10000;
                position.Maximum_Pay__c = 15000;
            }
        }
    }
}