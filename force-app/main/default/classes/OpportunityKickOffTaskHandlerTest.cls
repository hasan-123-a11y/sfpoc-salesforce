/**
 * Verifies kick-off Task creation when an Opportunity is won (SFPOC-8).
 */
@IsTest
private class OpportunityKickOffTaskHandlerTest {

    private static final Integer BULK_SIZE = 200;
    private static final String CLOSED_WON = 'Closed Won';
    private static final String CLOSED_LOST = 'Closed Lost';
    private static final String PROSPECTING = 'Prospecting';

    private static List<Opportunity> buildOpportunities(Integer count, String stageName) {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            opps.add(new Opportunity(
                Name = 'SFPOC-8 Test ' + i,
                StageName = stageName,
                CloseDate = Date.today()
            ));
        }
        return opps;
    }

    private static List<Task> kickOffTasks() {
        return [
            SELECT Id, OwnerId, WhatId, Subject, Priority, ActivityDate
            FROM Task
            WHERE Subject = :OpportunityKickOffTaskHandler.TASK_SUBJECT
        ];
    }

    private static Opportunity reload(Opportunity opp) {
        return [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp.Id];
    }

    private static void assertKickOffTask(Task t, Opportunity opp) {
        Assert.areEqual(opp.Id, t.WhatId, 'Task should be related to the Opportunity');
        Assert.areEqual(opp.OwnerId, t.OwnerId, 'Task should be assigned to the Opportunity owner');
        Assert.areEqual('Schedule kick-off meeting', t.Subject, 'Unexpected subject');
        Assert.areEqual('High', t.Priority, 'Priority should be High');
        Assert.areEqual(Date.today().addDays(3), t.ActivityDate, 'Due date should be today + 3 days');
    }

    @IsTest
    static void insertAsClosedWonCreatesTask() {
        Opportunity opp = buildOpportunities(1, CLOSED_WON)[0];

        Test.startTest();
        insert opp;
        Test.stopTest();

        List<Task> tasks = kickOffTasks();
        Assert.areEqual(1, tasks.size(), 'Exactly one kick-off Task expected');
        assertKickOffTask(tasks[0], reload(opp));
    }

    @IsTest
    static void updateToClosedWonCreatesTask() {
        Opportunity opp = buildOpportunities(1, PROSPECTING)[0];
        insert opp;

        Test.startTest();
        opp.StageName = CLOSED_WON;
        update opp;
        Test.stopTest();

        List<Task> tasks = kickOffTasks();
        Assert.areEqual(1, tasks.size(), 'Exactly one kick-off Task expected');
        assertKickOffTask(tasks[0], reload(opp));
    }

    @IsTest
    static void updateWhenAlreadyWonCreatesNoTask() {
        Opportunity opp = buildOpportunities(1, CLOSED_WON)[0];
        insert opp;
        Assert.areEqual(1, kickOffTasks().size(), 'Setup: one Task from the insert');

        Test.startTest();
        opp.Description = 'Unrelated change';
        update opp;
        opp.StageName = CLOSED_WON;
        update opp;
        Test.stopTest();

        Assert.areEqual(1, kickOffTasks().size(), 'No new Task when the Opportunity was already won');
    }

    @IsTest
    static void otherStageChangesCreateNoTask() {
        List<Opportunity> opps = new List<Opportunity>{
            buildOpportunities(1, PROSPECTING)[0],
            buildOpportunities(1, PROSPECTING)[0],
            buildOpportunities(1, CLOSED_LOST)[0]
        };

        Test.startTest();
        insert opps;
        opps[0].StageName = 'Qualification';
        opps[1].StageName = CLOSED_LOST;
        opps[2].StageName = PROSPECTING;
        update opps;
        Test.stopTest();

        Assert.areEqual(0, kickOffTasks().size(), 'No Task for stages other than Closed Won');
    }

    @IsTest
    static void changeFromClosedWonCreatesNoTask() {
        Opportunity opp = buildOpportunities(1, CLOSED_WON)[0];
        insert opp;

        Test.startTest();
        opp.StageName = PROSPECTING;
        update opp;
        Test.stopTest();

        Assert.areEqual(1, kickOffTasks().size(), 'Only the Task from the insert should exist');
    }

    @IsTest
    static void bulkUpdateToClosedWonCreatesOneTaskPerOpportunity() {
        List<Opportunity> opps = buildOpportunities(BULK_SIZE, PROSPECTING);
        insert opps;

        Test.startTest();
        for (Opportunity opp : opps) {
            opp.StageName = CLOSED_WON;
        }
        update opps;
        Test.stopTest();

        Map<Id, Opportunity> oppsById = new Map<Id, Opportunity>([
            SELECT Id, OwnerId FROM Opportunity WHERE Id IN :opps
        ]);
        List<Task> tasks = kickOffTasks();
        Assert.areEqual(BULK_SIZE, tasks.size(), 'One Task per Opportunity expected');

        Set<Id> relatedIds = new Set<Id>();
        for (Task t : tasks) {
            assertKickOffTask(t, oppsById.get(t.WhatId));
            relatedIds.add(t.WhatId);
        }
        Assert.areEqual(BULK_SIZE, relatedIds.size(), 'Each Opportunity should have exactly one Task');
    }

    @IsTest
    static void standardUserWinCreatesTask() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueKey = String.valueOf(Crypto.getRandomInteger()).replace('-', '');
        User standardUser = new User(
            ProfileId = standardProfile.Id,
            LastName = 'SFPOC-8 Standard',
            Alias = 'sfpoc8',
            Email = 'sfpoc8.standard@example.com',
            Username = 'sfpoc8.standard.' + uniqueKey + '@example.com',
            TimeZoneSidKey = 'Europe/London',
            LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert standardUser;

        Opportunity opp;
        Test.startTest();
        System.runAs(standardUser) {
            opp = buildOpportunities(1, PROSPECTING)[0];
            insert opp;
            opp.StageName = CLOSED_WON;
            update opp;
        }
        Test.stopTest();

        opp = reload(opp);
        List<Task> tasks = kickOffTasks();
        Assert.areEqual(1, tasks.size(), 'Exactly one kick-off Task expected');
        Assert.areEqual(standardUser.Id, opp.OwnerId, 'Setup: Opportunity owned by the standard user');
        assertKickOffTask(tasks[0], opp);
    }
}
