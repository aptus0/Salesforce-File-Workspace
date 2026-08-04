# Salesforce File Workspace

An open-source, deployable Salesforce file-management workspace built with **Lightning Web Components**, **Apex**, and **Salesforce Files**. It combines Windows-style navigation with an Odoo-inspired operational layout while respecting Salesforce sharing and CRUD/FLS controls.

## Highlights

- Three-panel workspace: navigation, file canvas, inspector
- Virtual folder hierarchy without duplicating `ContentDocument` records
- Grid and list views, search, breadcrumbs, upload and download
- Native Salesforce Lightning icons (`standard:folder`, `standard:file`, `doctype:*`)
- User-mode SOQL/DML and explicit permission checks
- Responsive, keyboard-friendly SLDS interface
- No external server, OAuth proxy, namespace, or OrgPulse dependency

## Architecture

```text
sfwFileWorkspace (LWC)
        │
SFWFileController
        │
SFWFileService ─── SFWFileSecurity
        │
SFWFileRepository
        │
ContentDocument / ContentVersion / SFW_Folder__c / SFW_File_Placement__c
```

`SFW_Folder__c` stores a virtual hierarchy. `SFW_File_Placement__c` references a Salesforce `ContentDocument` by Id, allowing files to be organized without copying their binary content.

## Install

```bash
git clone https://github.com/aptus0/Salesforce-File-Workspace.git
cd Salesforce-File-Workspace
sf org login web --alias file-workspace
sf project deploy start --manifest manifest/package.xml --target-org file-workspace
sf org assign permset --name Salesforce_File_Workspace_User --target-org file-workspace
```

Open **File Workspace** from the Salesforce App Launcher.

## Development

```bash
npm install
npm run validate
sf apex run test --tests SFWFileServiceTest --code-coverage --result-format human
```

## Security model

- Apex classes use `with sharing`.
- Queries use `WITH USER_MODE`; DML uses `as user`.
- Permission-set access is explicit.
- Files remain governed by native Salesforce Files sharing.
- Virtual folders never store file bodies or credentials.

## Roadmap

- Drag-and-drop folder moves
- Record picker for Account, Opportunity, Case and custom objects
- Version timeline and approval workflow
- Tags, favorites, recycle bin and saved views
- Experience Cloud sharing mode
- Optional Einstein document classification

## License

MIT — built for the Salesforce developer community.
