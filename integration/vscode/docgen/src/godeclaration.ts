import * as vscode from 'vscode';
import { getProjectList } from './extension';
import { DocProject } from './docProjects';

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
                    for (i = 0; i < project.Files.length; i++) {
                        var docFile = project.Files[i];
                        for (j = 0; j < docFile.Keys.length; j++) {
                            var docKey = docFile.Keys[j];
                            if (docKey.Key == word) {
                                var file = docFile.File
                                var folder = vscode.workspace.rootPath
                                if (folder != null && folder != undefined) {
                                    var file1 = file.toLowerCase();
                                    var folder1 = folder.toLowerCase();
                                    if (file1.indexOf(folder1) == 0) {
                                        file = folder + file.substring(folder.length);
                                    }
                                }
                                return new vscode.Location(vscode.Uri.file(file), new vscode.Position(docKey.Line, 0));
                            }
                        }
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
