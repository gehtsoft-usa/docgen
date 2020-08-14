@echo off
if not exist src mkdir src
if not exist src\raw mkdir src\raw
del src\raw\*.* /q /s >nul
"%docgen%\bin\docgen.exe" prepareproject.xml








