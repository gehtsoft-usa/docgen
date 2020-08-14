import * as vscode from 'vscode';

export class DocsourceContext {
    constructor() {
        this.CurrentTag = null;
        this.CurrentProperty = null;
        this.OpenBBCode = null;
        this.CurrentValue = null;
        this.BBCodeAllowed = false;
        this.CanBeProperty = false;
    }

    CurrentTag : string | null;
    CurrentProperty : string | null;
    CurrentValue : string | null;
    OpenBBCode : string | null;
    BBCodeAllowed : boolean;
    CanBeProperty : boolean;

}

var tagRegex = /^\s*@(end|article|group|class|member|table|row|col|example|list|list-item|return|exception|see|declaration|param|tab|header)\s*$/
var propRegex = /^\s*@(\w+)\s*=(.*)$"/
var preTypedRegex = /^\s*@(\w*)/

//The function scans the document from the beginning to the current position
//and finds the tag and the property at the cursor position
export function findContext(document: vscode.TextDocument, position: vscode.Position) : DocsourceContext  {
    
    var rc = new DocsourceContext();
   
    var tagStack = new Array();

    var i, line;
    for (i = 0; i <= position.line && i < document.lineCount; i++) {
        line = document.lineAt(i).text;
        if (i == position.line && line.length > position.character){
            line = line.substring(0, position.character);
        }

        var test = tagRegex.exec(line);
        if (test != null) {
            if (test[1] == "end") {
                if (tagStack.length > 0) {
                    tagStack.pop();
                }
            } else {
                tagStack.push(test[1]);
            }
            continue;
        }
        
        if (i == position.line) {
            test = propRegex.exec(line);
            
            if (test != null) {
            rc.CurrentProperty = test[1];
            rc.CurrentValue = test[2];
            line = test[2];
            } else {
                test = preTypedRegex.exec(line);
                if (test != null) {
                    rc.CanBeProperty = true;
                    rc.CurrentProperty = test[1];
                }
            }
        }
    }

    if (tagStack.length > 0) {
        rc.CurrentTag = tagStack.pop();
    }


    if (rc.CurrentTag != null && rc.CurrentProperty == null || 
        rc.CurrentProperty == "brief" ||
        (rc.CurrentTag == "declaration" && rc.CurrentProperty == "params") ||
        (rc.CurrentTag == "declaration" && rc.CurrentProperty == "return"))
            rc.BBCodeAllowed = true;
    return rc;
}

var bbCodeRegex = /\[([/]?\w+)(=[^\]]*)?\](.*)$/
 
//The function scans the document from current position back as long as the text may
//contain bb codes at this location and finds the currently open bbcode tag
export function findOpenBbcode(document: vscode.TextDocument, position: vscode.Position) : string | null {
    var i0 = position.line;
    var line, line0;
    while (i0 > 0) {
        line0 = document.lineAt(i0);
        if (line0 == null) {
            continue;
        }
        line = line0.text;
        if (line != null) {
            line = line.trimLeft();
        }
        if (line.startsWith('@')) {
            break;
        }
        i0 = i0 - 1;
    }
    
    var bbCodeStack = new Array();
    
    for (var i = i0; i <= position.line; i++) {
        line = document.lineAt(i).text;
        if (i == position.line && line.length > position.character){
            line = line.substring(0, position.character);
        }
        var r = bbCodeRegex.exec(line);
        while (r != null) {
            var tag = r[1];
            if (tag[0] == '/') {
                tag = tag.substring(1);
                if (bbCodeStack.length > 0 && bbCodeStack[bbCodeStack.length - 1] == tag) {
                    bbCodeStack.pop();
                }
            } else {
                bbCodeStack.push(tag);
            }
            line = r[3];
            r = bbCodeRegex.exec(line);
        }
    }
    if (bbCodeStack.length > 0) {
        return bbCodeStack[bbCodeStack.length  - 1];
    }
    return null;
}
