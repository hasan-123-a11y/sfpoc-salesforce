/**
 * Opportunity trigger. Keep logic in handler classes.
 */
trigger OpportunityTrigger on Opportunity (after insert, after update) {
    OpportunityKickOffTaskHandler.createKickOffTasks(Trigger.new, Trigger.oldMap);
}
