public with sharing class EmployeeTriggerHandler {
    
    public static void beforeInsert(List<Employee__c> newList) {  
    }
         
    public static void afterInsert(List<Employee__c> newList) {
        updatePresentEmployeeCountUsingParentChildSoql(newList); //NOPMD(BlankMethod)
    }
         
    public static void beforeUpdate(List<Employee__c> newList, Map<Id, Employee__c> oldMap) { //NOPMD(BlankMethod)
    }
         
    public static void afterUpdate(List<Employee__c> newList, Map<Id, Employee__c> oldMap) { //NOPMD(BlankMethod)
    } 
        
    public static void beforeDelete(List<Employee__c> oldList) {
    }

    public static void afterUndelete(List<Employee__c> newList){
        undeletingEmployeeSetActive(newList);
        updateEmployeeRecordCount(newList);
        updatePresentEmployeeCountUsingParentChildSoql(newList);
    }
         
    public static void afterDelete(List<Employee__c> oldList) {
        updateEmployeeRecordCount(oldList);
        updatePresentEmployeeCountUsingParentChildSoql(oldList); //NOPMD(BlankMethod)
    }

    private static void updateEmployeeRecordCount(List<Employee__c> employees){ //Q17
        Set<Id> accountIds = new Set<Id>();
        for (Employee__c employee : employees) {
            accountIds.add(employee.AccountId__c);
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult resultArray : [SELECT AccountId__c accId, COUNT(Id) countEmployee FROM Employee__c
            WHERE AccountId__c IN :accountIds GROUP BY AccountId__c]) {
            accountsToUpdate.add(new Account(
                Id = (Id)resultArray.get('accId'),
                Left_Employee_Count__c = (Integer)resultArray.get('countEmployee')
            ));
        }
        update accountsToUpdate;
    }

    private static void undeletingEmployeeSetActive(List<Employee__c> employeeList){ //Q18
        Set<String> employeeIds = new Set<String>();
        for (Employee__c employee : employeeList) {
            employeeIds.add(employee.Employee_ID__c);
        }
        List<Employee__c> employeequery = [SELECT Active__c FROM Employee__c WHERE Employee_ID__c IN :employeeIds];
        for(Employee__c employee : employeequery) {
            employee.Active__c	= True;
        }
        update employeequery;
    }

    private static void updatePresentEmployeeCountUsingParentChildSoql(List<Employee__c> employees){ //Q20
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        for (Employee__c employee : employees) {
            accountIds.add(employee.AccountId__c);
        }
        List<Account> accountList = [SELECT Id,NumberOfEmployees,(SELECT Employee_ID__c FROM Employees__r) from Account WHERE Id IN : accountIds];
        for(Account account : accountList) {
            Account a = new Account();
            a.id = account.id;
            a.NumberOfEmployees = account.Employees__r.size();
            accountsToUpdate.add(a);
        }
        update accountsToUpdate;
    }
}