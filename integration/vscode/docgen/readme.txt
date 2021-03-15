1) To compile for the first time

a) run `npm install`
b) create `out` folder

2) To compile call Terminal -> Run Build Task (Ctrl-Shift-B) -> npm: compile
TBD: understand why it is not called automatically

3) A grammar...

a) A grammar for Visual Studio Code is used in Texmate XML format.

b) Textmate grammars are NOT BNF style grammars,
   they are regexp-based text analyzing grammars with stack of
   context (similar to FAR colorer approach) instead.

   Supposedly anyone who dares to touch the grammar would better be
   experienced in creating regex-based grammars.

c) This particular grammar is designed using Iro
   The source file of the grammar in iro format is stored in
   parent folder (look for ../grammar.iro).

   Use https://eeyo.io/iro/ to modify, debug and convert the grammar
   to textmate format.

3) Packing and Installing extension

a) make sure that vsce is installed

npm install -g vsce

Make sure that is in path
C:\Users\<<username>>\AppData\Roaming\npm\

b) pack extension

vsce package

c) installing extension

code --install-extension extension-package.vsix

VSCE requires the following in order to be able to run this extension

- git installed

4) Supported Features

- Syntax highlighting and folding for ds files
- Autocomplete for tag names, property names, enum property values and bbcodes
- Autocomplete with identifiers for @ingroup property, [link] and [clink] bbcodes
- Go declaration command is Supported
- a separate command docgen.gomatch is used to navigate b/w end and start of a tag,
  do not forget to add it to keymap

Limitations

- The docgen project file must be called project.xml and must be kept in the
  root folder of the project
- It is strictly recommended to keep both project and source files in UTF-8 encoding
- Identifiers are updated only at file or project save. Any newly ids in not saved files
  are ignored
- Identifiers autocomplete works only if file is included into a project.
  If new file included via folder, you may have to open project file and save it again.
