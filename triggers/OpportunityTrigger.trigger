trigger OpportunityTrigger on Opportunity (after insert) {
  switch on Trigger.operationType {
        when BEFORE_INSERT {
            OpportunityTriggerHandler.beforeInsert(Trigger.new);
        }
        when AFTER_INSERT {
            OpportunityTriggerHandler.afterInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            OpportunityTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
        when AFTER_UPDATE {
            OpportunityTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
        when BEFORE_DELETE {
            OpportunityTriggerHandler.beforeDelete(Trigger.old);
        }
        when AFTER_DELETE {
            OpportunityTriggerHandler.afterDelete(Trigger.old);
        }
    }
}