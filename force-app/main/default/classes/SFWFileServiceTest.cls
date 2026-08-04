@IsTest
private class SFWFileServiceTest {
    @TestSetup
    static void setup() {
        insert new SFW_Folder__c(Name = 'Sales', Icon_Name__c = 'standard:folder');
    }
    @IsTest
    static void createsNestedFolder() {
        SFW_Folder__c parent = [SELECT Id FROM SFW_Folder__c LIMIT 1];
        Test.startTest();
        SFW_Folder__c child = new SFWFileService().createFolder('Opportunities', parent.Id);
        Test.stopTest();
        System.assertEquals('Opportunities', child.Name);
        System.assertEquals(parent.Id, child.Parent_Folder__c);
    }
    @IsTest
    static void loadsFolderTree() {
        Test.startTest();
        SFWFileService.WorkspacePayload payload = new SFWFileService().loadWorkspace(null, null);
        Test.stopTest();
        System.assertEquals(1, payload.folders.size());
        System.assertEquals(0, payload.files.size());
    }
    @IsTest
    static void rejectsBlankFolderName() {
        try {
            new SFWFileService().createFolder(' ', null);
            System.assert(false, 'Expected validation error');
        } catch (AuraHandledException expected) {
            System.assertNotEquals(null, expected);
        }
    }
}
