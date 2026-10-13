/**
 * Creates a welcome email Task for the Contact owner when a Contact with an Email is created (SFPOC-9).
 */
public with sharing class ContactWelcomeTaskHandler {

    @TestVisible
    private static final String TASK_SUBJECT = 'Send welcome email';
    @TestVisible
    private static final String TASK_PRIORITY = 'Normal';
    @TestVisible
    private static final Integer DUE_IN_DAYS = 2;

    /**
     * Creates one Task per new Contact that has an Email address.
     * @param newList Trigger.new of an after insert
     */
    public static void createWelcomeTasks(List<Contact> newList) {
        List<Task> tasks = new List<Task>();
        Date dueDate = Date.today().addDays(DUE_IN_DAYS);

        for (Contact con : newList) {
            if (String.isNotBlank(con.Email)) {
                tasks.add(new Task(
                    OwnerId = con.OwnerId,
                    WhoId = con.Id,
                    WhatId = con.AccountId,
                    Subject = TASK_SUBJECT,
                    Priority = TASK_PRIORITY,
                    ActivityDate = dueDate
                ));
            }
        }

        if (!tasks.isEmpty()) {
            insert as user tasks;
        }
    }
}
