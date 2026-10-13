/**
 * Verifies welcome email Task creation for new Contacts (SFPOC-9).
 */
@IsTest
private class ContactWelcomeTaskHandlerTest {

    private static final Integer BULK_SIZE = 200;

    private static List<Contact> buildContacts(Integer count, Id accountId, Boolean withEmail) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(new Contact(
                LastName = 'SFPOC-9 Test ' + i,
                AccountId = accountId,
                Email = withEmail ? 'sfpoc9.test' + i + '@example.com' : null
            ));
        }
        return contacts;
    }

    private static List<Task> welcomeTasks() {
        return [
            SELECT Id, OwnerId, WhoId, WhatId, Subject, Priority, ActivityDate
            FROM Task
            WHERE Subject = :ContactWelcomeTaskHandler.TASK_SUBJECT
        ];
    }

    private static void assertWelcomeTask(Task t, Contact con) {
        Assert.areEqual(con.Id, t.WhoId, 'Task should be related to the Contact');
        Assert.areEqual(con.AccountId, t.WhatId, 'Task should be related to the Contact\'s Account');
        Assert.areEqual(con.OwnerId, t.OwnerId, 'Task should be assigned to the Contact owner');
        Assert.areEqual('Send welcome email', t.Subject, 'Unexpected subject');
        Assert.areEqual('Normal', t.Priority, 'Priority should be Normal');
        Assert.areEqual(Date.today().addDays(2), t.ActivityDate, 'Due date should be today + 2 days');
    }

    private static Contact reload(Contact con) {
        return [SELECT Id, OwnerId, AccountId FROM Contact WHERE Id = :con.Id];
    }

    @IsTest
    static void insertWithEmailAndAccountCreatesTask() {
        Account acc = new Account(Name = 'SFPOC-9 Account');
        insert acc;
        Contact con = buildContacts(1, acc.Id, true)[0];

        Test.startTest();
        insert con;
        Test.stopTest();

        List<Task> tasks = welcomeTasks();
        Assert.areEqual(1, tasks.size(), 'Exactly one welcome Task expected');
        assertWelcomeTask(tasks[0], reload(con));
    }

    @IsTest
    static void insertWithEmailWithoutAccountCreatesTask() {
        Contact con = buildContacts(1, null, true)[0];

        Test.startTest();
        insert con;
        Test.stopTest();

        List<Task> tasks = welcomeTasks();
        Assert.areEqual(1, tasks.size(), 'Exactly one welcome Task expected');
        Assert.isNull(tasks[0].WhatId, 'Task should have no Related To without an Account');
        assertWelcomeTask(tasks[0], reload(con));
    }

    @IsTest
    static void insertWithoutEmailCreatesNoTask() {
        Test.startTest();
        insert buildContacts(1, null, false);
        Test.stopTest();

        Assert.areEqual(0, welcomeTasks().size(), 'No Task for a Contact without Email');
    }

    @IsTest
    static void updateCreatesNoTask() {
        List<Contact> contacts = new List<Contact>{
            buildContacts(1, null, true)[0],
            buildContacts(1, null, false)[0]
        };
        insert contacts;
        Assert.areEqual(1, welcomeTasks().size(), 'Setup: one Task from the insert');

        Test.startTest();
        contacts[0].Email = 'sfpoc9.changed@example.com';
        contacts[1].Email = 'sfpoc9.added@example.com';
        update contacts;
        Test.stopTest();

        Assert.areEqual(1, welcomeTasks().size(), 'No new Task when an existing Contact is edited');
    }

    @IsTest
    static void bulkInsertCreatesOneTaskPerContactWithEmail() {
        List<Contact> contacts = buildContacts(BULK_SIZE, null, true);
        contacts.addAll(buildContacts(BULK_SIZE, null, false));

        Test.startTest();
        insert contacts;
        Test.stopTest();

        Map<Id, Contact> withEmail = new Map<Id, Contact>([
            SELECT Id, OwnerId, AccountId FROM Contact WHERE Id IN :contacts AND Email != null
        ]);
        List<Task> tasks = welcomeTasks();
        Assert.areEqual(BULK_SIZE, tasks.size(), 'One Task per Contact with Email expected');

        Set<Id> relatedIds = new Set<Id>();
        for (Task t : tasks) {
            Assert.isTrue(withEmail.containsKey(t.WhoId), 'Task should belong to a Contact with Email');
            assertWelcomeTask(t, withEmail.get(t.WhoId));
            relatedIds.add(t.WhoId);
        }
        Assert.areEqual(BULK_SIZE, relatedIds.size(), 'Each Contact should have exactly one Task');
    }

    @IsTest
    static void standardUserInsertCreatesTask() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueKey = String.valueOf(Crypto.getRandomInteger()).replace('-', '');
        User standardUser = new User(
            ProfileId = standardProfile.Id,
            LastName = 'SFPOC-9 Standard',
            Alias = 'sfpoc9',
            Email = 'sfpoc9.standard@example.com',
            Username = 'sfpoc9.standard.' + uniqueKey + '@example.com',
            TimeZoneSidKey = 'Europe/London',
            LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert standardUser;

        Contact con;
        Test.startTest();
        System.runAs(standardUser) {
            Account acc = new Account(Name = 'SFPOC-9 Standard Account');
            insert acc;
            con = buildContacts(1, acc.Id, true)[0];
            insert con;
        }
        Test.stopTest();

        con = reload(con);
        List<Task> tasks = welcomeTasks();
        Assert.areEqual(1, tasks.size(), 'Exactly one welcome Task expected');
        Assert.areEqual(standardUser.Id, con.OwnerId, 'Setup: Contact owned by the standard user');
        assertWelcomeTask(tasks[0], con);
    }
}
