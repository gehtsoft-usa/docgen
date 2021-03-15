@echo off
if not exist src mkdir src
if not exist src\raw mkdir src\raw
del src\raw\*.* /q /s >nul
del out.xml > nul
..\..\source\asm2xml\bin\Debug\net50\AssemblyToXml.exe D:\develop\experiments\Asm2XmlTester\Asm2XmlTester\bin\Debug\net5.0\Asm2XmlTester.dll /out:out.xml
"%docgen%\bin\docgen.exe" prepareproject.xml








