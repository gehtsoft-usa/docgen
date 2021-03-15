@echo off
if not exist dst mkdir dst
if not exist dst\img mkdir dst\img
if not exist dst\menu mkdir dst\menu
if not exist dst\pageImages mkdir dst\pageImages
del dst\*.* /q /s >nul

"%docgen%\bin\docgen.exe" project.xml

if %errorlevel% == 0 goto make
goto exit

:make
copy img\*.png dst\img\*.*
copy html\*.html dst\*.*
copy "%docgen%\template\html\menu\*.*" dst\menu\*.*
copy "%docgen%\template\html\pageImages\*.*" dst\pageImages\*.*

:exit