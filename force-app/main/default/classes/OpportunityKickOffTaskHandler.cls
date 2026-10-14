/**
 * Creates a kick-off Task for the Opportunity owner when an Opportunity is won (SFPOC-8).
 */
public with sharing class OpportunityKickOffTaskHandler {

    @TestVisible
    private static final String TASK_SUBJECT = 'Schedule kick-off meeting';
    @TestVisible
    private static final String TASK_PRIORITY = 'High';
    @TestVisible
    private static final Integer DUE_IN_DAYS = 3;

    /**
     * Creates one Task per Opportunity that became won.
     * @param newList Trigger.new
     * @param oldMap  Trigger.oldMap, null on insert
     */
    public static void createKickOffTasks(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Task> tasks = new List<Task>();
        Date dueDate = Date.today().addDays(DUE_IN_DAYS);

        for (Opportunity opp : newList) {
            if (becameWon(opp, oldMap == null ? null : oldMap.get(opp.Id))) {
                tasks.add(new Task(
                    OwnerId = opp.OwnerId,
                    WhatId = opp.Id,
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

    private static Boolean becameWon(Opportunity newOpp, Opportunity oldOpp) {
        if (!newOpp.IsWon) {
            return false;
        }
        return oldOpp == null || !oldOpp.IsWon;
    }
}
