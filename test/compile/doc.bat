@echo off
tasklist /FI "WINDOWTITLE eq Test Reference" > %temp%\hhtest.txt

findstr /c:"hh.exe" %temp%\hhtest.txt >nul

if %errorlevel% == 0 goto :closechm
del %temp%\hhtest.txt
if not exist dst mkdir dst
if not exist dst\img mkdir dst\img
if not exist dst\res mkdir dst\res
if not exist dst\menu mkdir dst\menu
if not exist dst\highlighter mkdir dst\highlighter
if not exist dst\pageImages mkdir dst\pageImages
del dst\*.* /q /s >nul

set docgenbin=..\source\app\bin\release\net45

"%docgenbin%\docgen.exe" project.xml

if %errorlevel% == 0 goto make
goto exit

:make

copy img\*.png dst\img\*.*
copy html\*.html dst\*.*
copy "%docgen%\template\html\res\*.*" dst\res\*.*
cd dst
"%HTMLHelpDir%\hhc.exe" project.hhp
cd ..
copy "%docgen%\template\html\highlighter\*.*" dst\highlighter\*.*
copy "%docgen%\template\html\menu\*.*" dst\menu\*.*
copy "%docgen%\template\html\pageImages\*.*" dst\pageImages\*.*

goto exit

:closechm
del %temp%\hhtest.txt
echo The chm file is opened. Close it before compiling
goto exit