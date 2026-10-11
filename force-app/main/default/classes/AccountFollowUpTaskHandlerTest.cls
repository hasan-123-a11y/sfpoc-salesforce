/**
 * Verifies follow-up Task creation when Account.Health_Status__c becomes Critical (SFPOC-7).
 */
@IsTest
private class AccountFollowUpTaskHandlerTest {

    private static final Integer BULK_SIZE = 200;

    private static List<Account> buildAccounts(Integer count, String healthStatus) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'SFPOC-7 Test ' + i, Health_Status__c = healthStatus));
        }
        return accounts;
    }

    private static List<Task> followUpTasks() {
        return [
            SELECT Id, OwnerId, WhatId, Subject, Priority, ActivityDate
            FROM Task
            WHERE Subject = :AccountFollowUpTaskHandler.TASK_SUBJECT
        ];
    }

    private static void assertFollowUpTask(Task t, Account acc) {
        Assert.areEqual(acc.Id, t.WhatId, 'Task should be related to the Account');
        Assert.areEqual(acc.OwnerId, t.OwnerId, 'Task should be assigned to the Account owner');
        Assert.areEqual(AccountFollowUpTaskHandler.TASK_SUBJECT, t.Subject, 'Unexpected subject');
        Assert.areEqual('High', t.Priority, 'Priority should be High');
        Assert.areEqual(Date.today().addDays(2), t.ActivityDate, 'Due date should be today + 2 days');
    }

    @IsTest
    static void insertAsCriticalCreatesTask() {
        Account acc = buildAccounts(1, 'Critical')[0];

        Test.startTest();
        insert acc;
        Test.stopTest();

        acc = [SELECT Id, OwnerId FROM Account WHERE Id = :acc.Id];
        List<Task> tasks = followUpTasks();
        Assert.areEqual(1, tasks.size(), 'Exactly one follow-up Task expected');
        assertFollowUpTask(tasks[0], acc);
    }

    @IsTest
    static void updateToCriticalCreatesTask() {
        Account acc = buildAccounts(1, 'Healthy')[0];
        insert acc;

        Test.startTest();
        acc.Health_Status__c = 'Critical';
        update acc;
        Test.stopTest();

        acc = [SELECT Id, OwnerId FROM Account WHERE Id = :acc.Id];
        List<Task> tasks = followUpTasks();
        Assert.areEqual(1, tasks.size(), 'Exactly one follow-up Task expected');
        assertFollowUpTask(tasks[0], acc);
    }

    @IsTest
    static void updateWhenAlreadyCriticalCreatesNoTask() {
        Account acc = buildAccounts(1, 'Critical')[0];
        insert acc;
        Assert.areEqual(1, followUpTasks().size(), 'Setup: one Task from the insert');

        Test.startTest();
        acc.Description = 'Unrelated change';
        update acc;
        acc.Health_Status__c = 'Critical';
        update acc;
        Test.stopTest();

        Assert.areEqual(1, followUpTasks().size(), 'No new Task when status was already Critical');
    }

    @IsTest
    static void nonCriticalValuesCreateNoTask() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Blank'),
            new Account(Name = 'Healthy', Health_Status__c = 'Healthy'),
            new Account(Name = 'At Risk', Health_Status__c = 'At Risk')
        };

        Test.startTest();
        insert accounts;
        accounts[0].Health_Status__c = 'At Risk';
        accounts[1].Health_Status__c = 'At Risk';
        accounts[2].Health_Status__c = 'Healthy';
        update accounts;
        Test.stopTest();

        Assert.areEqual(0, followUpTasks().size(), 'No Task for non-Critical values');
    }

    @IsTest
    static void changeFromCriticalCreatesNoTask() {
        Account acc = buildAccounts(1, 'Critical')[0];
        insert acc;

        Test.startTest();
        acc.Health_Status__c = 'Healthy';
        update acc;
        acc.Health_Status__c = null;
        update acc;
        Test.stopTest();

        Assert.areEqual(1, followUpTasks().size(), 'Only the Task from the insert should exist');
    }

    @IsTest
    static void bulkUpdateToCriticalCreatesOneTaskPerAccount() {
        List<Account> accounts = buildAccounts(BULK_SIZE, 'Healthy');
        insert accounts;

        Test.startTest();
        for (Account acc : accounts) {
            acc.Health_Status__c = 'Critical';
        }
        update accounts;
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id, OwnerId FROM Account WHERE Id IN :accounts
        ]);
        List<Task> tasks = followUpTasks();
        Assert.areEqual(BULK_SIZE, tasks.size(), 'One Task per Account expected');

        Set<Id> relatedIds = new Set<Id>();
        for (Task t : tasks) {
            assertFollowUpTask(t, accountsById.get(t.WhatId));
            relatedIds.add(t.WhatId);
        }
        Assert.areEqual(BULK_SIZE, relatedIds.size(), 'Each Account should have exactly one Task');
    }
}
