/**
 * Creates a follow-up Task for the Account owner when Account.Health_Status__c becomes Critical (SFPOC-7).
 */
public with sharing class AccountFollowUpTaskHandler {

    @TestVisible
    private static final String CRITICAL = 'Critical';
    @TestVisible
    private static final String TASK_SUBJECT = 'Follow up: account health is Critical';
    @TestVisible
    private static final String TASK_PRIORITY = 'High';
    @TestVisible
    private static final Integer DUE_IN_DAYS = 2;

    /**
     * Creates one Task per Account whose Health Status changed to Critical.
     * @param newList Trigger.new
     * @param oldMap  Trigger.oldMap, null on insert
     */
    public static void createFollowUpTasks(List<Account> newList, Map<Id, Account> oldMap) {
        List<Task> tasks = new List<Task>();
        Date dueDate = Date.today().addDays(DUE_IN_DAYS);

        for (Account acc : newList) {
            if (becameCritical(acc, oldMap == null ? null : oldMap.get(acc.Id))) {
                tasks.add(new Task(
                    OwnerId = acc.OwnerId,
                    WhatId = acc.Id,
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

    private static Boolean becameCritical(Account newAcc, Account oldAcc) {
        if (newAcc.Health_Status__c != CRITICAL) {
            return false;
        }
        return oldAcc == null || oldAcc.Health_Status__c != CRITICAL;
    }
}
