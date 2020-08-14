import * as vscode from 'vscode';

var tagRegex = /^(\s*)@([\w\-]+)\s*$/

class tagMatch {
    constructor (tag : string, startLine : number, startChar : number) {
        this.tag = tag;
        this.startLine = startLine;
        this.startChar = startChar;
        this.endLine = -1;
    }
    tag : string;
    startLine : number;
    startChar : number;
    endLine : number;
}

function findAllMatches(document : vscode.TextDocument) : tagMatch[]  {
    var stack : tagMatch[] = Array();
    var r : tagMatch[] = Array();
    for (var i = 0 ; i < document.lineCount; i++) {
        var line = document.lineAt(i).text
        var res = tagRegex.exec(line);
        if (res != null) {
            if (res[2] == "end") {
                if (stack.length > 0) {
                    var e = stack.pop();
                    if (e != undefined) {
                        e.endLine =  i;
                    }
                }
            } else {
                var e1 = new tagMatch(res[2], i, res[1].length);
                stack.push(e1);
                r.push(e1);
            }
        }
    }
    return r;
}

function goMatch(editor : vscode.TextEditor | undefined) {
    if (editor == undefined) {
        return ;
    }
    var matches = findAllMatches(editor.document);
    var line = editor.selection.start.line;
    try {
        for (var i = 0; i < matches.length; i++) {
            if (matches[i].startLine == line && matches[i].endLine != -1) {
                editor.selection = new vscode.Selection(new vscode.Position(matches[i].endLine, matches[i].startChar), new vscode.Position(matches[i].endLine, matches[i].startChar));
                editor.revealRange(editor.selection, vscode.TextEditorRevealType.Default);
                break;
            } else if (matches[i].endLine == line) {
                editor.selection = new vscode.Selection(new vscode.Position(matches[i].startLine, matches[i].startChar), new vscode.Position(matches[i].startLine, matches[i].startChar));
                editor.revealRange(editor.selection, vscode.TextEditorRevealType.Default);
                break;
            }
        }   
    }
    catch (error) {
        ;
    }
}

export function registerMatchCommands(context: vscode.ExtensionContext) {
    var command1 = vscode.commands.registerCommand('docgen.goMatch', () => goMatch(vscode.window.activeTextEditor));
    context.subscriptions.push(command1);
}