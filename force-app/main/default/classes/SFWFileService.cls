public with sharing class SFWFileService {
    private final SFWFileRepository repository;
    public SFWFileService() {
        this(new SFWFileRepository());
    }
    @TestVisible
    private SFWFileService(SFWFileRepository repository) {
        this.repository = repository;
    }

    public class FolderItem {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Id parentId;
        @AuraEnabled
        public String iconName;
        @AuraEnabled
        public Datetime modifiedDate;
    }
    public class FileItem {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String extension;
        @AuraEnabled
        public String fileType;
        @AuraEnabled
        public Long size;
        @AuraEnabled
        public Id versionId;
        @AuraEnabled
        public Datetime modifiedDate;
        @AuraEnabled
        public String ownerName;
        @AuraEnabled
        public Boolean favorite;
    }
    public class WorkspacePayload {
        @AuraEnabled
        public List<FolderItem> folders = new List<FolderItem>();
        @AuraEnabled
        public List<FileItem> files = new List<FileItem>();
    }

    public WorkspacePayload loadWorkspace(Id folderId, String searchTerm) {
        SFWFileSecurity.assertReadable();
        WorkspacePayload payload = new WorkspacePayload();
        for (SFW_Folder__c folder : repository.folders())
            payload.folders.add(toFolder(folder));
        if (folderId == null)
            return payload;
        List<SFW_File_Placement__c> placements = repository.placements(folderId);
        Set<Id> ids = new Set<Id>();
        Map<Id, Boolean> favorites = new Map<Id, Boolean>();
        for (SFW_File_Placement__c placement : placements) {
            Id documentId = SFWFileSecurity.contentDocumentId(placement.Content_Document_Id__c);
            ids.add(documentId);
            favorites.put(documentId, placement.Is_Favorite__c);
        }
        for (ContentDocument document : repository.documents(ids, searchTerm))
            payload.files.add(toFile(document, favorites.get(document.Id)));
        return payload;
    }

    public SFW_Folder__c createFolder(String name, Id parentFolderId) {
        SFWFileSecurity.assertFolderCreateable();
        if (String.isBlank(name))
            throw new AuraHandledException('Folder name is required.');
        return repository.insertFolder(
            new SFW_Folder__c(Name = name.trim(), Parent_Folder__c = parentFolderId, Icon_Name__c = 'standard:folder')
        );
    }

    public void placeFiles(Id folderId, List<Id> contentDocumentIds) {
        SFWFileSecurity.assertPlacementCreateable();
        if (folderId == null || contentDocumentIds == null || contentDocumentIds.isEmpty())
            return;
        Set<Id> existing = new Set<Id>();
        for (SFW_File_Placement__c item : repository.placements(folderId))
            existing.add(SFWFileSecurity.contentDocumentId(item.Content_Document_Id__c));
        List<SFW_File_Placement__c> additions = new List<SFW_File_Placement__c>();
        for (Id documentId : contentDocumentIds)
            if (!existing.contains(documentId))
                additions.add(
                    new SFW_File_Placement__c(Folder__c = folderId, Content_Document_Id__c = String.valueOf(documentId))
                );
        if (!additions.isEmpty())
            repository.insertPlacements(additions);
    }

    public void moveFiles(Id targetFolderId, List<Id> contentDocumentIds) {
        SFWFileSecurity.assertPlacementDeleteable();
        Set<String> ids = stringIds(contentDocumentIds);
        List<SFW_File_Placement__c> removals = repository.placementsForDocuments(ids, null);
        if (!removals.isEmpty())
            repository.deletePlacements(removals);
        placeFiles(targetFolderId, contentDocumentIds);
    }

    public void removeFiles(Id folderId, List<Id> contentDocumentIds) {
        SFWFileSecurity.assertPlacementDeleteable();
        Set<String> ids = stringIds(contentDocumentIds);
        List<SFW_File_Placement__c> removals = repository.placementsForDocuments(ids, folderId);
        if (!removals.isEmpty())
            repository.deletePlacements(removals);
    }

    private static FolderItem toFolder(SFW_Folder__c record) {
        FolderItem item = new FolderItem();
        item.id = record.Id;
        item.name = record.Name;
        item.parentId = record.Parent_Folder__c;
        item.iconName = record.Icon_Name__c;
        item.modifiedDate = record.LastModifiedDate;
        return item;
    }
    private static FileItem toFile(ContentDocument record, Boolean favorite) {
        FileItem item = new FileItem();
        item.id = record.Id;
        item.title = record.Title;
        item.extension = record.FileExtension;
        item.fileType = record.FileType;
        item.size = record.ContentSize;
        item.versionId = record.LatestPublishedVersionId;
        item.modifiedDate = record.ContentModifiedDate;
        item.ownerName = record.Owner.Name;
        item.favorite = favorite == true;
        return item;
    }
    private static Set<String> stringIds(List<Id> values) {
        Set<String> result = new Set<String>();
        if (values != null)
            for (Id value : values)
                result.add(String.valueOf(value));
        return result;
    }
}
