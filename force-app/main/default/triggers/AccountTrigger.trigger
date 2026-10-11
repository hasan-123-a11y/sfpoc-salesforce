/**
 * Account trigger. Keep logic in handler classes.
 */
trigger AccountTrigger on Account (after insert, after update) {
    AccountFollowUpTaskHandler.createFollowUpTasks(Trigger.new, Trigger.oldMap);
}
