trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete) {
    switch on Trigger.operationType {
          when BEFORE_INSERT {
              ContactTriggerHandler.beforeInsert(Trigger.new);
          }
          when AFTER_INSERT {    
              ContactTriggerHandler.afterInsert(Trigger.new);
          }
          when BEFORE_UPDATE {    
              ContactTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
          }
          when AFTER_UPDATE {      
              ContactTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
          }
          when BEFORE_DELETE {      
              ContactTriggerHandler.beforeDelete(Trigger.old);
          }
          when AFTER_DELETE {      
              ContactTriggerHandler.beforeDelete(Trigger.old);
          }
      }
  }