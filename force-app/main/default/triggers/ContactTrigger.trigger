/**
 * Contact trigger. Keep logic in handler classes.
 */
trigger ContactTrigger on Contact (after insert) {
    ContactWelcomeTaskHandler.createWelcomeTasks(Trigger.new);
}
