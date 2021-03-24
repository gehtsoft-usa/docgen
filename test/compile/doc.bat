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

"%docgen%\bin\docgen.exe" project.xml

copy img\*.png dst\img\*.*
copy html\*.html dst\*.*
copy "%docgen%\template\html\highlighter\*.*" dst\highlighter\*.* > nul
copy "%docgen%\template\html\menu\*.*" dst\menu\*.* > nul
copy "%docgen%\template\html\pageImages\*.*" dst\pageImages\*.* > nul
copy "%docgen%\template\html\res\*.*" dst\res\*.* > nul

