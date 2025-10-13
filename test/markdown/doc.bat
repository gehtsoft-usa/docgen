@echo off

REM Set docgen path
set docgen=..\..

REM Create destination directory
if not exist "dst" mkdir dst

REM Clean destination directory
del /q dst\*

REM Run docgen to generate markdown documentation
dotnet "%docgen%\source\app\bin\Release\net80\docgen.dll" project.xml

echo Documentation generated in dst/
