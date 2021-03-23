tasklist /FI "WINDOWTITLE eq TestDoc" > %temp%\testdoc.txt
findstr /c:"php.exe" %temp%\testdoc.txt >nul
if %errorlevel% == 0 goto :open
call startserver.bat
sleep 5
:open
del %temp%\testdoc.txt
start http://localhost:8000/web-content.html