trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
  switch on Trigger.operationType {
        when BEFORE_INSERT {
            AccountTriggerHandler.beforeInsert(Trigger.new);
        }
        when AFTER_INSERT {    
            AccountTriggerHandler.afterInsert(Trigger.new);
        }
        when BEFORE_UPDATE {    
            AccountTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
        when AFTER_UPDATE {      
            AccountTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
        when BEFORE_DELETE {      
            AccountTriggerHandler.beforeDelete(Trigger.old);
        }
        when AFTER_DELETE {      
            AccountTriggerHandler.beforeDelete(Trigger.old);
        }
    }
}