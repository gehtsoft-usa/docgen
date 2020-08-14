import * as vscode from 'vscode';
import { initializeAutocomplete } from './autocomplete';
import { DocProjectList } from './docProjects';
import { initializeGoDeclaration } from './godeclaration';
import { registerMatchCommands } from './tagmatching';

var  docProjects : DocProjectList = new DocProjectList();

export function getProjectList() {
    return docProjects;
}

export function activate(context: vscode.ExtensionContext) {
    initializeAutocomplete(context);
    initializeGoDeclaration(context);
    registerMatchCommands(context);

    vscode.workspace.onDidSaveTextDocument((document: vscode.TextDocument) => {
        if (document.fileName.toLowerCase().endsWith(".ds")) {
            docProjects.onSave(document.fileName);
            return ;
        }
        if (document.fileName.toLowerCase().endsWith("project.xml")) {
            docProjects.onSaveProject(document.fileName);
        }
	});
}

