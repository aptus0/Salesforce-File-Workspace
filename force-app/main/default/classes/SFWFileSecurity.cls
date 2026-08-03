public with sharing class SFWFileSecurity {
    public static void assertReadable() {
        if (
            !SFW_Folder__c.SObjectType.getDescribe().isAccessible() ||
            !ContentDocument.SObjectType.getDescribe().isAccessible()
        )
            throw new AuraHandledException('You do not have access to File Workspace.');
    }
    public static void assertFolderCreateable() {
        if (!SFW_Folder__c.SObjectType.getDescribe().isCreateable())
            throw new AuraHandledException('You cannot create folders.');
    }
    public static void assertPlacementCreateable() {
        if (!SFW_File_Placement__c.SObjectType.getDescribe().isCreateable())
            throw new AuraHandledException('You cannot organize files.');
    }
    public static void assertPlacementDeleteable() {
        if (!SFW_File_Placement__c.SObjectType.getDescribe().isDeletable())
            throw new AuraHandledException('You cannot move or remove files.');
    }
    public static Id contentDocumentId(String value) {
        try {
            Id parsed = (Id) value;
            if (parsed.getSObjectType() != ContentDocument.SObjectType)
                throw new TypeException();
            return parsed;
        } catch (Exception ignored) {
            throw new AuraHandledException('Invalid ContentDocument id.');
        }
    }
}
