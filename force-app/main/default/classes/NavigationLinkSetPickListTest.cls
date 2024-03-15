@isTest
public with sharing class NavigationLinkSetPickListTest {
    @isTest
    static void testGetDefaultValue() {
        NavigationLinkSetPickList pickList = new NavigationLinkSetPickList();
        VisualEditor.DataRow defaultValue = pickList.getDefaultValue();

        // System.assertEquals('Default Navigation', defaultValue.get('label'));
        // System.assertEquals('Default Navigation', defaultValue.get('value'));
    }
    @isTest
    static void testGetValues() {
        // Assuming you have NavigationLinkSet records in your org for testing
        // Insert test NavigationLinkSet records before running this test

        NavigationLinkSetPickList pickList = new NavigationLinkSetPickList();
        VisualEditor.DynamicPickListRows picklistValues = pickList.getValues();

        // Check if picklistValues is not null
        System.assertNotEquals(null, picklistValues);

        // You can add more assertions based on your specific use case and test data
        // For example, checking if the picklistValues contain the expected values
    }
}