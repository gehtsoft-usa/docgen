import * as vscode from 'vscode';
import { getProjectList } from './extension';

async function provideDeclaration(document : vscode.TextDocument, 
    position : vscode.Position, 
    token : vscode.CancellationToken) : Promise<vscode.Declaration | null> {
        var wordRange = document.getWordRangeAtPosition(position, /[\w\d_\.\-]+/);
        if (wordRange == null || wordRange.start.character < 3) {
            return null;
        }

        var preRange = new vscode.Range(new vscode.Position(wordRange.start.line, 0), new vscode.Position(wordRange.start.line, wordRange.start.character))
        var preWord = document.getText(preRange)
        var word = document.getText(wordRange);
        
        if (preWord.endsWith("[link=") ||
            preWord.endsWith("[clink=") ||
            preWord.endsWith("@ingroup=")) {
            var projectList = getProjectList();   
            try { 
                var project  = await projectList.findOrCreateProject(document.fileName);
                if (project != null) {
                    var i, j
                    var foundFile = null;
                    var foundKey = null;

                    for (i = 0; i < project.Files.length && foundKey === null; i++) {
                        var docFile = project.Files[i];
                        for (j = 0; j < docFile.Keys.length && foundKey === null; j++) {
                            var docKey = docFile.Keys[j];
                            if (docKey.Key == word) {
                                foundFile = docFile;
                                foundKey = docKey;
                            }  
                        }
                    }

                    if (foundKey == null) {
                        for (i = 0; i < project.Files.length; i++) {
                            docFile = project.Files[i];
                            for (j = 0; j < docFile.Keys.length; j++) {
                                docKey = docFile.Keys[j];
                                if (docKey.Key.length > word.length &&
                                    docKey.Key.substr(0, word.length) == word) {
                                    if (foundKey == null || 
                                        docKey.Key.length > foundKey.Key.length) {
                                        foundFile = docFile;
                                        foundKey = docKey;
                                    }  
                                }
                            }
                        }
                    }
                    
                    if (foundKey != null && foundFile != null &&
                        vscode.workspace.workspaceFolders != null &&
                        vscode.workspace.workspaceFolders.length >= 1) {
                        var file = foundFile.File
                        var folder = vscode.workspace.workspaceFolders[0].uri.path;
                        if (folder != null && folder != undefined) {
                            var file1 = file.toLowerCase();
                            var folder1 = folder.toLowerCase();
                            if (file1.indexOf(folder1) == 0) {
                                file = folder + file.substring(folder.length);
                            }
                        }
                        return new vscode.Location(vscode.Uri.file(file), new vscode.Position(foundKey.Line, 0));
                    }
                } 
            }
            catch (e) {
                return null;
                
            }

        }
        return null;
}

export function initializeGoDeclaration(context: vscode.ExtensionContext) {
    const declarationProvider = vscode.languages.registerDeclarationProvider('docgen',
    {
        provideDeclaration(document : vscode.TextDocument, 
            position : vscode.Position, token : vscode.CancellationToken) : vscode.ProviderResult<vscode.Declaration> {
            return provideDeclaration(document, position, token);
        }
    });
    context.subscriptions.push(declarationProvider);
}
