@echo off
if not exist .\bin mkdir .\bin

if exist .\bin\docgen.exe attrib -r .\bin\docgen.exe
if exist .\bin\docgen2.parser.dll attrib -r .\bin\docgen2.parser.dll
if exist .\bin\docgen2.output.dll attrib -r .\bin\docgen2.output.dll

cd source
dotnet restore docgen.sln
msbuild docgen.sln /p:Configuration="Release"
cd ..
copy .\source\app\bin\release\net60\docgen.exe .\bin
copy .\source\app\bin\release\net60\docgen.pdb .\bin
copy .\source\app\bin\release\net60\docgen2.parser.dll .\bin
copy .\source\app\bin\release\net60\docgen2.parser.pdb .\bin
copy .\source\app\bin\release\net60\docgen2.output.dll .\bin
copy .\source\app\bin\release\net60\docgen2.output.pdb .\bin
