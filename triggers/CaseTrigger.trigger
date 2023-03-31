trigger CaseTrigger on Case (before insert, after insert, before update, after update, before delete, after delete) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CaseTriggerHandler.beforeInsert(Trigger.new);
        }
        when AFTER_INSERT {
            CaseTriggerHandler.afterInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            CaseTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap); 
        }
        when AFTER_UPDATE {
            CaseTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
        when BEFORE_DELETE {
            CaseTriggerHandler.beforeDelete(Trigger.old);
        }
        when AFTER_DELETE {
            CaseTriggerHandler.afterDelete(Trigger.old);
        }
    }
}