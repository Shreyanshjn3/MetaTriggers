public with sharing class EmployeeService {
    // public static List<Account> getAccount(Set<Id> accountIds){
    //     List<Account> accounts = [SELECT Id,NumberOfEmployees,(SELECT AccountId__c FROM Employees1__r) FROM Account WHERE Id IN : accountIds];
    //     return !accounts.isEmpty() ? accounts : NULL;
    // }
}