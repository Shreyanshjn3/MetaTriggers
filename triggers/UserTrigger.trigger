trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete) { //NOPMD
    
    switch on Trigger.operationType {
        when BEFORE_INSERT {
        }
    
        when BEFORE_UPDATE {
        }
    
        when BEFORE_DELETE {
            
        }
    
        when AFTER_INSERT {
            UserTriggerHandler.afterInsert(Trigger.new);
        }
    
        when AFTER_UPDATE {
            UserTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    
        when AFTER_DELETE {
            UserTriggerHandler.afterDelete(Trigger.old);
        }
    }
}