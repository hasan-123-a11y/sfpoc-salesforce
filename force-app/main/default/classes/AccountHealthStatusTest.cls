/**
 * Verifies the metadata of Account.Health_Status__c (SFPOC-1).
 */
@IsTest
private class AccountHealthStatusTest {

    private static final String FIELD_NAME = 'Health_Status__c';
    private static final List<String> EXPECTED_VALUES = new List<String>{ 'Healthy', 'At Risk', 'Critical' };

    /**
     * The field exists, is a restricted picklist and has exactly the expected active values in order.
     */
    @IsTest
    static void healthStatusIsRestrictedPicklistWithExpectedValues() {
        Schema.SObjectField field = Schema.SObjectType.Account.fields.getMap().get(FIELD_NAME);
        Assert.isNotNull(field, 'Account.' + FIELD_NAME + ' should exist');

        Schema.DescribeFieldResult describe = field.getDescribe();
        Assert.areEqual(Schema.DisplayType.PICKLIST, describe.getType(), 'Field should be a picklist');
        Assert.isTrue(describe.isRestrictedPicklist(), 'Picklist should be restricted');

        List<String> activeValues = new List<String>();
        for (Schema.PicklistEntry entry : describe.getPicklistValues()) {
            if (entry.isActive()) {
                activeValues.add(entry.getValue());
            }
        }
        Assert.areEqual(EXPECTED_VALUES, activeValues, 'Active values should match exactly and in order');
    }
}
