public with sharing class SFWFileController {
    @AuraEnabled(cacheable=true)
    public static SFWFileService.WorkspacePayload loadWorkspace(Id folderId, String searchTerm) {
        return new SFWFileService().loadWorkspace(folderId, searchTerm);
    }

    @AuraEnabled
    public static SFW_Folder__c createFolder(String name, Id parentFolderId) {
        return new SFWFileService().createFolder(name, parentFolderId);
    }

    @AuraEnabled
    public static void placeFiles(Id folderId, List<Id> contentDocumentIds) {
        new SFWFileService().placeFiles(folderId, contentDocumentIds);
    }

    @AuraEnabled
    public static void moveFiles(Id targetFolderId, List<Id> contentDocumentIds) {
        new SFWFileService().moveFiles(targetFolderId, contentDocumentIds);
    }

    @AuraEnabled
    public static void removeFiles(Id folderId, List<Id> contentDocumentIds) {
        new SFWFileService().removeFiles(folderId, contentDocumentIds);
    }
}
