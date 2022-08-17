import * as vscode from 'vscode';
import { findContext, findOpenBbcode } from './context';
import { getProjectList } from './extension';

var tagDictionary = [
    {context : null, options : ["class", "group", "article"] },
    {context : "group", options : ["end", "see", "example", "table", "list", "header", "note",
                                   "key", "ingroup", "if", "transform", "title", "brief",
                                   "sortarticles", "sortclasses", "sortgroups", "importhhk", "importhhc", "order"
                                ] },
    {context : "article", options : ["end", "see", "example", "table", "list", "header", "note",
                                     "key", "ingroup", "if", "transform", "title", "brief",
                                     "aliasId", "excludeFromList"
                                    ] },
    {context : "table", options : ["end", "row", "if", "width"] },
    {context : "row", options : ["end", "col", "if", "header"] },
    {context : "col", options : ["end", "see", "example", "table", "list", "gray", "width"] },
    {context : "list", options : ["end", "list", "list-item", "type"] },
    {context : "list-item", options : ["end", "if"] },
    {context : "example", options : ["end", "tab",
                                     "if", "title", "show", "tabs", "gray", "highlight", "declaration"] },
    {context : "tab", options : ["end", "if", "title", "highlight"]},                                    
    {context : "class", options : ["end", "see", "example", "table", "list", "param", "member", "header", "note",
                                   "key", "ingroup", "if", "transform", "name", "brief",
                                   "sig", "parent", "declname", "prefix", "type", "sort", "classnameinkey", 
                                   "import", "membersToContent", "writeSignatures"
                                ] },
    {context : "member", options : ["end", "see", "example", "table", "list", "param", "return", "exception", "declaration", "header", "note",
                                    "if", "key", "name", "transform", "brief",
                                    "custom", "sig", "divisor", "index", "type", "visibility", "scope", "excludeFromList"
                                   ] },
    {context : "param", options : ["end", "see", "example", "table", "list", "note", "name"] },
    {context : "exception", options : ["end", "see", "example", "table", "list", "name"] },
    {context : "return", options : ["end", "see", "example", "table", "list"] },
    {context : "declaration", options : ["end", "if", "language", "prefix", "name", "suffix", "namesuffix", "custom", "return", "params"] },
    {context : "header", options : ["end", "level"]},
    {context : "note", options : ["end", "type", "table", "list"]},
];

var propertyDictionary = [
    {tag : "group", property : "sortarticles", options : ["yes", "no"]},
    {tag : "group", property : "sortgroups", options : ["yes", "no"]},
    {tag : "group", property : "sortclasses", options : ["yes", "no"]},
    {tag : "group", property : "order", options : ["sorted", "custom"]},
    {tag : "group", property : "transform", options : ["yes", "no", "def"]},
    {tag : "article", property : "transform", options : ["yes", "no", "def"]},
    {tag : "article", property : "excludeFromList", options : ["yes", "no"]},
    {tag : "class", property : "transform", options : ["yes", "no", "def"]},
    {tag : "class", property : "sort", options : ["yes", "no"]},
    {tag : "class", property : "type", options : ["ref class", "class", "interface", "struct", "value", "enum", "lua_table", "js_object", "xml-schema", "functions", "tags", "sql"]},
    {tag : "class", property : "classnameinkey", options : ["true", "false", "both"]},
    {tag : "class", property : "writeSignatures", options : ["yes", "no", "def"]},
    {tag : "member", property : "transform", options : ["yes", "no", "def"]},
    {tag : "member", property : "type", options : ["property", "field", "method", "constructor", "function"]},
    {tag : "member", property : "visibility", options : ["public", "protected", "private", "package"]},
    {tag : "member", property : "scope", options : ["class", "instance"]},
    {tag : "member", property : "excludeFromList", options : ["yes", "no"]},
    {tag : "example", property : "show", options : ["yes", "no", "always"]},
    {tag : "example", property : "gray", options : ["yes", "no"]},
    {tag : "example", property : "tabs", options : ["yes", "no"]},
    {tag : "example", property : "declaration", options : ["yes", "no"]},
    {tag : "example", property : "highlight", options: ["c", "cpp", "cs", "lua", "basic", "vb", "xml", "html", "sql", "bash", "python", "js", "cshtml", "objc", "go", "java", "luax"]},
    {tag : "tab", property : "highlight", options: ["c", "cpp", "cs", "lua", "basic", "vb", "xml", "html", "sql", "bash", "python", "js", "cshtml", "objc", "go", "java", "luax"]},
    {tag : "declaration", property : "language", options : ["cpp", "cs", "vb", "mq4", "el", "idl", "java", "lua", "javaScript", "xml", "html", "sql", "python"]},
    {tag : "list", property : "type", options : ["num", "dot"]},
    {tag : "row", property : "header", options : ["yes", "no"]},
    {tag : "col", property : "gray", options : ["yes", "no"]},
    {tag : "note", property : "type", options : ["note", "quote", "warning"]},
]

var bbCodes = ["b", "i", "u", "s", "c", "red", "green", "blue", "gray", "size", "color", "sup", "sub", "link", "clink", "url", "nil", "br", "eurl", "img"]

var keyRegEx1 = /^\s*@ingroup=(.*)$/
var keyRegEx2 = /.*\[c?link=(.*)$/

export function initializeAutocomplete(context: vscode.ExtensionContext) {
    const bbCodeProvider = vscode.languages.registerCompletionItemProvider(
        'docgen',
        {
            provideCompletionItems(document: vscode.TextDocument, position: vscode.Position, token : vscode.CancellationToken, context1 : vscode.CompletionContext) : vscode.CompletionList {
                var docSourceContext = findContext(document, position);
                var rc : vscode.CompletionList = new vscode.CompletionList;
                var i;
                if (docSourceContext.BBCodeAllowed) {
                    var open = findOpenBbcode(document, position);
                    if (open != null) {
                        var item = new vscode.CompletionItem("/" + open, vscode.CompletionItemKind.Text);
                        item.preselect = true;
                        rc.items.push(item);
                    }
                    for (i = 0; i < bbCodes.length; i++) {
                        rc.items.push(new vscode.CompletionItem(bbCodes[i], vscode.CompletionItemKind.Text));
                    }
                }
                return rc;
			}
		},
        '[' 
    );

    const dsTagProvider = vscode.languages.registerCompletionItemProvider(
        'docgen',
        {
			provideCompletionItems(document: vscode.TextDocument, position: vscode.Position, token : vscode.CancellationToken, context1 : vscode.CompletionContext) : vscode.CompletionList {
                var docSourceContext = findContext(document, position);
                var i, j;
                var rc : vscode.CompletionList = new vscode.CompletionList;

                if (!docSourceContext.CanBeProperty) {
                    return rc;
                }

                
                for (i = 0; i < tagDictionary.length; i++) {
                    if (tagDictionary[i].context == docSourceContext.CurrentTag) {
                        for (j = 0; j < tagDictionary[i].options.length; j++) {
                            if (docSourceContext.CurrentProperty != null) {
                                if (!tagDictionary[i].options[j].startsWith(docSourceContext.CurrentProperty)) {
                                    continue;
                                }
                            }
                            rc.items.push(new vscode.CompletionItem(tagDictionary[i].options[j], vscode.CompletionItemKind.Text));
                        }
                        break;
                    }
                }
                return rc;
			}
		},
        '@' 
    );

    const dsValueProvider = vscode.languages.registerCompletionItemProvider(
        'docgen',
        {
            async provideCompletionItems(document: vscode.TextDocument, position: vscode.Position, token : vscode.CancellationToken, context1 : vscode.CompletionContext) : Promise<vscode.CompletionList> {
                var currentLine = document.lineAt(position.line).text;
                if (currentLine.length > position.character) {
                    currentLine = currentLine.substring(0, position.character);
                }

                var isKey = false;
                var groupsOnly = false;
                var key = null;
                var test;
                var rc : vscode.CompletionList = new vscode.CompletionList;
                var i, j;

                test = keyRegEx1.exec(currentLine);
                if (test != null) {
                    isKey = true;
                    key = test[1];
                    groupsOnly = true;
                } else {
                    test = keyRegEx2.exec(currentLine);
                    if (test != null) {
                        isKey = true;
                        key = test[1];
                    }
                }
                if (isKey && key != null) {
                    var project = await getProjectList().findOrCreateProject(document.fileName);
                    var range = new vscode.Range(new vscode.Position(position.line, position.character - key.length), 
                                                 new vscode.Position(position.line, position.character));
                    
                    if (project != null) {
                        project.belongsToProject(document.fileName);
                        for (i = 0; i < project.Files.length; i++) {
                            var docFile = project.Files[i];

                            for (j = 0; j < docFile.Keys.length; j++) {
                                var docKey = docFile.Keys[j];
                                
                                if (groupsOnly && docKey.KeyType != 'g') {
                                    continue;
                                }
                                
                                if (key != null && key.length > 0) {
                                    if (docKey.Key.indexOf(key) < 0) {
                                        continue;
                                    }
                                }
                                var item = new vscode.CompletionItem(docKey.Key, vscode.CompletionItemKind.Text);
                                if (range != null)
                                    item.range = range;
                                if (docKey.Key.length > 49) {
                                    item.label = '…' + docKey.Key.substring(docKey.Key.length - 49);
                                    item.sortText = docKey.Key;
                                    item.filterText = docKey.Key;
                                    item.insertText = docKey.Key;
                                }

                                rc.items.push(item) ;
                            }
                        }
                    }
                    if (rc.items.length == 20) {
                        rc.isIncomplete = true;
                    }
                }
                else {
                    var docSourceContext = findContext(document, position);
                    for (i = 0; i < propertyDictionary.length; i++) {
                        if (propertyDictionary[i].tag == docSourceContext.CurrentTag &&
                            propertyDictionary[i].property == docSourceContext.CurrentProperty) {
                            for (j = 0; j < propertyDictionary[i].options.length; j++) {
                                if (docSourceContext.CurrentValue != null && !propertyDictionary[i].options[j].startsWith(docSourceContext.CurrentValue)) {
                                        continue;
                                    }
                                item = new vscode.CompletionItem(propertyDictionary[i].options[j], vscode.CompletionItemKind.Text);
                                rc.items.push(item);
                            }
                            break;
                        }
                    }
                }
                return rc;
			}
		},
        '=' 
    );

    context.subscriptions.push(dsValueProvider, dsTagProvider, bbCodeProvider);
}

