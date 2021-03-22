@echo off
set docgen=%cd%/../
dotnet build project.proj /t:MakeDoc
