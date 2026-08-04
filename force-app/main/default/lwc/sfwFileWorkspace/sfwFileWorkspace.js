import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadWorkspace from '@salesforce/apex/SFWFileController.loadWorkspace';
import createFolderRecord from '@salesforce/apex/SFWFileController.createFolder';
import placeFiles from '@salesforce/apex/SFWFileController.placeFiles';

const ICONS = {
    PDF: 'doctype:pdf',
    WORD: 'doctype:word',
    EXCEL: 'doctype:excel',
    POWER_POINT: 'doctype:ppt',
    IMAGE: 'doctype:image',
    TEXT: 'doctype:txt',
    ZIP: 'doctype:zip',
    default: 'doctype:unknown',
};

export default class SfwFileWorkspace extends LightningElement {
    folders = [];
    files = [];
    selectedFolderId;
    selectedFileId;
    searchTerm = '';
    view = 'grid';
    loading = true;
    showFolderDialog = false;
    newFolderName = '';

    connectedCallback() {
        this.refresh();
    }
    async refresh() {
        this.loading = true;
        try {
            const data = await loadWorkspace({
                folderId: this.selectedFolderId || null,
                searchTerm: this.searchTerm || null,
            });
            this.folders = data.folders || [];
            this.files = (data.files || []).map((file) => this.presentFile(file));
            if (!this.files.some((file) => file.id === this.selectedFileId)) this.selectedFileId = null;
        } catch (error) {
            this.toast('Workspace unavailable', error?.body?.message || 'Unable to load files.', 'error');
        } finally {
            this.loading = false;
        }
    }

    get navigationItems() {
        return [
            {
                id: '',
                name: 'Home',
                iconName: 'utility:home',
                count: this.folders.length,
                className: this.selectedFolderId ? 'nav-item' : 'nav-item active',
            },
            { id: 'recent', name: 'Recent', iconName: 'utility:clock', count: '', className: 'nav-item' },
            { id: 'favorites', name: 'Favorites', iconName: 'utility:favorite', count: '', className: 'nav-item' },
        ];
    }
    get folderItems() {
        return this.folders.map((folder) => ({
            ...folder,
            iconName: folder.iconName || 'standard:folder',
            className: folder.id === this.selectedFolderId ? 'nav-item active' : 'nav-item',
        }));
    }
    get selectedFolder() {
        return this.folders.find((folder) => folder.id === this.selectedFolderId);
    }
    get selectedFile() {
        return this.files.find((file) => file.id === this.selectedFileId);
    }
    get workspaceTitle() {
        return this.selectedFolder?.name || 'Workspace overview';
    }
    get resultLabel() {
        return `${this.files.length} ${this.files.length === 1 ? 'file' : 'files'}`;
    }
    get hasFiles() {
        return this.files.length > 0;
    }
    get isGrid() {
        return this.view === 'grid';
    }
    get isList() {
        return this.view === 'list';
    }
    get contentClass() {
        return `files ${this.view}`;
    }

    selectFolder(event) {
        const id = event.currentTarget.dataset.id;
        if (id === 'recent' || id === 'favorites') return;
        this.selectedFolderId = id || null;
        this.selectedFileId = null;
        this.refresh();
    }
    selectFile(event) {
        this.selectedFileId = event.currentTarget.dataset.id;
        this.files = this.files.map((file) => ({
            ...file,
            cardClass: file.id === this.selectedFileId ? 'file-card selected' : 'file-card',
        }));
    }
    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.refresh();
    }
    changeView(event) {
        this.view = event.currentTarget.dataset.view;
    }
    openFolderDialog() {
        this.showFolderDialog = true;
    }
    closeFolderDialog() {
        this.showFolderDialog = false;
        this.newFolderName = '';
    }
    changeFolderName(event) {
        this.newFolderName = event.target.value;
    }
    async createFolder() {
        try {
            await createFolderRecord({ name: this.newFolderName, parentFolderId: this.selectedFolderId || null });
            this.closeFolderDialog();
            await this.refresh();
            this.toast('Folder created', 'Your new workspace folder is ready.', 'success');
        } catch (error) {
            this.toast('Folder not created', error?.body?.message || 'Check your permissions.', 'error');
        }
    }
    async handleUploadFinished(event) {
        const documentIds = (event.detail.files || []).map((file) => file.documentId).filter(Boolean);
        if (documentIds.length) await placeFiles({ folderId: this.selectedFolderId, contentDocumentIds: documentIds });
        await this.refresh();
        this.toast('Upload complete', 'Files were uploaded and organized.', 'success');
    }
    downloadFile(event) {
        event.stopPropagation();
        window.open(`/sfc/servlet.shepherd/version/download/${event.currentTarget.dataset.version}`, '_blank');
    }
    presentFile(file) {
        const size = file.size || 0;
        return {
            ...file,
            iconName: ICONS[file.fileType] || ICONS.default,
            cardClass: 'file-card',
            sizeLabel: this.formatSize(size),
            modifiedLabel: new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(
                new Date(file.modifiedDate),
            ),
            meta: `${file.ownerName} · ${this.formatSize(size)}`,
            downloadUrl: `/sfc/servlet.shepherd/version/download/${file.versionId}`,
        };
    }
    formatSize(bytes) {
        if (bytes < 1024) return `${bytes} B`;
        if (bytes < 1048576) return `${(bytes / 1024).toFixed(1)} KB`;
        return `${(bytes / 1048576).toFixed(1)} MB`;
    }
    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
