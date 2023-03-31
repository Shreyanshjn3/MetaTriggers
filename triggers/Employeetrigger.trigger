trigger Employeetrigger on Employee__c (before insert, before update, before delete, after insert, after update, after delete) { //NOPMD
    
    switch on Trigger.operationType {
        when BEFORE_INSERT {
        }
    
        when BEFORE_UPDATE {
        }
    
        when BEFORE_DELETE {
            
        }
    
        when AFTER_INSERT {
        }
    
        when AFTER_UPDATE {
        }
    
        when AFTER_DELETE {
            EmployeeTriggerHandler.afterDelete(Trigger.old);
        }
        
        when AFTER_UNDELETE {
            EmployeeTriggerHandler.afterUndelete(Trigger.new);
        }
    }
}