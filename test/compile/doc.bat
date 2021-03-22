@echo off
del %temp%\hhtest.txt
if not exist dst mkdir dst
if not exist dst\img mkdir dst\img
if not exist dst\res mkdir dst\res
if not exist dst\menu mkdir dst\menu
if not exist dst\highlighter mkdir dst\highlighter
if not exist dst\pageImages mkdir dst\pageImages
if not exist dst\res mkdir dst\res
del dst\*.* /q /s >nul

set docgenbin=..\..\source\app\bin\debug\net45

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
copy "%docgen%\template\html\res\*.*" dst\res\*.*

goto exit

:closechm
del %temp%\hhtest.txt
echo The chm file is opened. Close it before compiling
goto exit