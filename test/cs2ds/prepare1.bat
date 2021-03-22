@echo off
if not exist src mkdir src
if not exist src\raw mkdir src\raw
del src\raw\*.* /q /s >nul
del out.xml > nul
..\..\source\asm2xml\bin\Release\net50\AssemblyToXml.exe D:\develop\components\BusinessSpecificComponents\Gehtsoft.Measurements\Gehtsoft.Measurements\bin\Release\netstandard2.0\Gehtsoft.Measurements.dll  /out:out1.xml
"%docgen%\bin\docgen.exe" prepareproject.xml








