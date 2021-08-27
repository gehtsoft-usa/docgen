import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';

var readlines = require('n-readlines');
var iconv = require('iconv-lite');
var DOMParser = require('xmldom').DOMParser;

//One key object
export class DocKey {
    constructor (key : string, keyType : string, line : number) {
        this.Key = key;
        this.Line = line;
        this.KeyType = keyType;
    }
    Key : string;
    KeyType : string;   //type of associated key object - g, a, c, or m
    Line : number;
}

var tagRegex = /^\s*@([\w\-]+)\s*$/
var keyRegex = /^\s*@key\s*=\s*(\S*)\s*$/i
var nameRegex = /^\s*@name\s*=\s*(\S*)\s*$/i

//One doc source file
export class DocSourceFile {
    constructor(file : string, encoding : string) {
        this.File = file.toLowerCase();
        this.Encoding = encoding;
        this.Keys = new Array();
    }
    File : string;
    Encoding : string;
    Keys : DocKey[];

    //Parses doc source file and grabs all keys
    initialize() {
        if (this.Keys.length > 0) {
            this.Keys = new Array();
        }

        var liner = new readlines(this.File);
        var line : any;
        var tagStack  = new Array();
        var memberKey = null;
        var memberLine = -1;
        var classKey = null;
        var classLine = -1;
        var lineNo = -1;
        var currentTag = null;
        while (line = liner.next()) {
            lineNo++;
            var text = iconv.decode(line, this.Encoding);
            var res = tagRegex.exec(text);
            if (res != null) {
                if (res[1] == "end") {
                    if (tagStack.length > 0) {
                        var popped = tagStack.pop();
                        if (popped == "class") {
                            if (classKey != null) {
                                this.Keys.push(new DocKey(classKey, "c", classLine));
                            }
                        } else if (popped == "member") {
                            if (memberKey != null) {
                                var memKey = memberKey;
                                if (classKey != null && classKey.length > 0) {
                                    memKey = classKey + '.' + memKey;
                                }
                                this.Keys.push(new DocKey(memKey, "m", memberLine));
                            }
                        }
                    }
                    if (tagStack.length == null) {
                        currentTag = null;
                    } else {
                        currentTag = tagStack[tagStack.length - 1];
                    }
                } else {
                    currentTag = res[1];
                    tagStack.push(res[1]);
                    if (currentTag == "class") {
                        classKey = null;
                    }
                    else if (currentTag == "member") {
                        memberKey = null;
                    }
                }
                continue;
            }
            if (tagStack.length == 0) {
                continue;
            }
            
            if (currentTag == "group" || currentTag == "article" || currentTag == "class" || currentTag == "member") {
                res = keyRegex.exec(text);
                if (res != null && res[1].length > 0) {
                    var key = res[1];
                    
                    if (currentTag == "group") {
                        this.Keys.push(new DocKey(key, "g", lineNo));
                        continue;
                    }

                    if (currentTag == "article") {
                        this.Keys.push(new DocKey(key, "a", lineNo));
                        continue;
                    }

                    if (currentTag == "class") {
                        classKey = key;
                        classLine = lineNo;
                    }

                    if (currentTag == "member") {
                        memberKey = key;
                        memberLine = lineNo;
                    }
                }
            }

            if (currentTag == "class") {
                res = nameRegex.exec(text);
                if (res != null && res[1].length > 0) {
                    if (classKey == null) {
                        classKey = res[1];
                        classLine = lineNo;
                    }
                }
            }

            if (currentTag == "member") {
                res = nameRegex.exec(text);
                if (res != null && res[1].length > 0) {
                    if (memberKey == null) {
                        memberKey = res[1];
                        memberLine = lineNo;
                    }
                }
            }
        }
    }
}

//One docsource project
export class DocProject {
    constructor(root : string, manager : DocProjectList) {
        this.Root = root.toLowerCase();
        this.Files = Array();
        this.Manager = manager;
    }
    Files : DocSourceFile[];
    Root : string;
    Manager : DocProjectList;


    //Checks whether the file with the name specified belongs to a project
    belongsToProject(file : string) : DocSourceFile | null {
        file = file.toLowerCase();
        for (var i = 0; i < this.Files.length; i++) {
            if (this.Files[i].File == file) {
                return this.Files[i];
            }
        }
        return null;
    }

    //reads project file and initializes all projects
    initialize() {
        var dir = path.dirname(this.Root);
        var content = fs.readFileSync(this.Root, 'utf8');
        var doc = new DOMParser().parseFromString(content, 'text/xml');
        var name;
        for (var i = 0; i < doc.documentElement.childNodes.length; i++) {
            var el = doc.documentElement.childNodes.item(i);
            if (el.nodeName == 'source' || el.nodeName == 'dg:source' || el.nodeName == 'ds:source') {
                for (var j = 0; j < el.childNodes.length; j++) {
                    var ch = el.childNodes.item(j);
                    if (ch.nodeName == 'file' || ch.nodeName == 'dg:file') {
                        if (!ch.hasAttribute('name') || !ch.hasAttribute('encoding')) {
                            continue;
                        }
                        name = ch.getAttribute('name');
                        var fileObj = new DocSourceFile(path.join(dir, name), ch.getAttribute('encoding'));
                        fileObj.initialize();
                        this.Files.push(fileObj);
                    } else if (ch.nodeName == 'folder' || ch.nodeName == 'dg:folder' || ch.nodeName == 'ds:folder') {
                        if (!ch.hasAttribute('name') || !ch.hasAttribute('encoding')) {
                            continue;
                        }
                        var folder = path.join(dir, ch.getAttribute('name'));
                        var files = fs.readdirSync(folder);
                        for (var k = 0; k < files.length; k++) {
                            var file = files[k];
                            if (file.toLowerCase().endsWith('.ds')) {
                                name = file;
                                fileObj = new DocSourceFile(path.join(folder, name), ch.getAttribute('encoding'));
                                fileObj.initialize();
                                this.Files.push(fileObj);
                            }
                        }
                    }
                }
            }
        }
    }
}

//Collection of all doc projects that are currently opened.
export class DocProjectList {
    constructor () {
        this.Projects = Array();
    }

    //Finds project by a root or by a file in the project
    findProject(file : string) : DocProject | null {
        for (var i = 0; i < this.Projects.length; i++) {
            if (this.Projects[i].Root == file) {
                return this.Projects[i];
            }
            if (this.Projects[i].belongsToProject(file)) {
                return this.Projects[i];
            }          
        }
        return null;
    }

    async findOrCreateProject(file : string) : Promise<DocProject | null> {
        var rc = this.findProject(file);
        if (rc != null) {
            return rc;
        }
        var root = this.getProjectRoot(file);
        if (root != null) {
        
            var promise = vscode.window.withProgress(
            {
                location: vscode.ProgressLocation.Notification,
                title: "parsing project...",
                cancellable: false
            }, (progress, token) => {
                return new Promise(resolve => {
                    if (root != null) {
                        rc = new DocProject(root, this);
                        this.Projects.push(rc);
                        rc.initialize();
                    }
                    resolve(undefined);
                });
            });
            await promise;
            return rc;
        }
        return null;

        
    }

    //checks whether a file is a correct project.xml 
    //file for docsource
    isProject(file : string) : boolean {
        if (fs.existsSync(file)) {
            var liner = new readlines(file);
            var line : any;
            for (var l = 0; l < 3; l++) {
                line = liner.next();
                if (!line) {
                    return false;
                }
                line = line.toString('utf8');
                if (line.indexOf("<dg:help-project") >= 0 || line.indexOf("<ds:help-project") >= 0) {
                    return true;
                }
            }
            return false;
        }
        return false;

    }

    //Finds a project.xml file in the same folder or any parent folder
    //for the file or folder specified.
    getProjectRoot(file : string) : string | null {
        if (!path.isAbsolute(file)) {
            file = path.resolve(file);
        }
        var dir = path.dirname(file);
        if (dir.length <= 3) {
            return null;
        }
        var candidate = dir + "\\project.xml";
        if (this.isProject(candidate)) {
            return candidate;
        }
        return this.getProjectRoot(dir);
    }

    //The method is called when a project.xml file is saved
    //
    //If the project file is a docsource project, if be updated
    onSaveProject(file : string) {
        if (this.isProject(file)) {
            var project = this.findProject(file);
            if (project == null) {
                vscode.window.withProgress(
                    {
                        location: vscode.ProgressLocation.Notification,
                        title: "parsing project...",
                        cancellable: false
                    }, (progress, token) => {
                        return new Promise(resolve => {
                            project = new DocProject(file, this);
                            this.Projects.push(project);
                            project.initialize();
                            resolve(undefined);
                        });
                    });
            }
            
        }
    }

    //The method called when a .DS file is saved
    //
    //If file belongs to any project it will be updated
    onSave(file : string) {
        var root = this.getProjectRoot(file);
        if (root == null) {
            return;
        }
        root = root.toLowerCase();
        for (var i = 0; i < this.Projects.length; i++) {
            if (this.Projects[i].Root == root) {
                var docFile = this.Projects[i].belongsToProject(file);
                if (docFile != null) {
                    docFile.initialize();
                }
            }
        }
    }
    

    Projects : DocProject[];
}

