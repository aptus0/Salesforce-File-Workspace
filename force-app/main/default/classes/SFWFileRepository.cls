public virtual with sharing class SFWFileRepository {
    public virtual List<SFW_Folder__c> folders() {
        return [
            SELECT Id, Name, Parent_Folder__c, Icon_Name__c, Is_Archived__c, LastModifiedDate
            FROM SFW_Folder__c
            WHERE Is_Archived__c = FALSE
            WITH USER_MODE
            ORDER BY Name
            LIMIT 500
        ];
    }

    public virtual List<SFW_File_Placement__c> placements(Id folderId) {
        return [
            SELECT Id, Folder__c, Content_Document_Id__c, Is_Favorite__c
            FROM SFW_File_Placement__c
            WHERE Folder__c = :folderId
            WITH USER_MODE
            LIMIT 1000
        ];
    }

    public virtual List<SFW_File_Placement__c> placementsForDocuments(Set<String> documentIds, Id folderId) {
        if (documentIds.isEmpty())
            return new List<SFW_File_Placement__c>();
        if (folderId == null) {
            return [SELECT Id FROM SFW_File_Placement__c WHERE Content_Document_Id__c IN :documentIds WITH USER_MODE];
        }
        return [
            SELECT Id
            FROM SFW_File_Placement__c
            WHERE Folder__c = :folderId AND Content_Document_Id__c IN :documentIds
            WITH USER_MODE
        ];
    }

    public virtual List<ContentDocument> documents(Set<Id> documentIds, String searchTerm) {
        if (documentIds.isEmpty())
            return new List<ContentDocument>();
        String pattern = String.isBlank(searchTerm) ? '%' : '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';
        return [
            SELECT
                Id,
                Title,
                FileExtension,
                FileType,
                ContentSize,
                LatestPublishedVersionId,
                ContentModifiedDate,
                Owner.Name
            FROM ContentDocument
            WHERE Id IN :documentIds AND Title LIKE :pattern
            WITH USER_MODE
            ORDER BY ContentModifiedDate DESC
            LIMIT 500
        ];
    }

    public virtual SFW_Folder__c insertFolder(SFW_Folder__c folder) {
        insert as user folder;
        return folder;
    }

    public virtual void insertPlacements(List<SFW_File_Placement__c> records) {
        insert as user records;
    }
    public virtual void deletePlacements(List<SFW_File_Placement__c> records) {
        delete as user records;
    }
}
