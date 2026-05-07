@echo off
if not exist src\model\dsmodel.ds goto :missingmodel
if not exist src\model\xmlmodel.ds goto :missingmodel

set docgen=%cd%/../
dotnet build project.proj /t:MakeDoc
goto :eof

:missingmodel
echo ERROR: model documentation sources are missing in src\model.
echo.
echo The .ds files for the model section are generated from prepare\model.
echo To produce them:
echo   1. cd prepare\model
echo   2. run do.bat (requires msxsl)
echo   3. copy out\dsmodel.ds and out\xmlmodel.ds into ..\..\src\model\
echo.
exit /b 1
