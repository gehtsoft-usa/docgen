@echo off
set vcver=2015
if not exist .\bin mkdir .\bin

if exist .\bin\docgen.exe attrib -r .\bin\docgen.exe
if exist .\bin\docgen2.parser.dll attrib -r .\bin\docgen2.parser.dll
if exist .\bin\docgen2.output.dll attrib -r .\bin\docgen2.output.dll

cd source\parser
call fxbuild %1
cd ..\output
call fxbuild %1
cd ..\app
call fxbuild %1
cd ..\..
copy .\source\app\bin\release\net45\docgen.exe .\bin
copy .\source\app\bin\release\net45\docgen.pdb .\bin
copy .\source\app\bin\release\net45\docgen2.parser.dll .\bin
copy .\source\app\bin\release\net45\docgen2.parser.pdb .\bin
copy .\source\app\bin\release\net45\docgen2.output.dll .\bin
copy .\source\app\bin\release\net45\docgen2.output.pdb .\bin
