@echo off


@echo ************************************************************************
@echo ---------------Start Cleaning Luadbg.--------------------

@if exist bin\*.*                                     del bin\*.* /f /q /s
@if exist obj\*.*                                     del obj\*.* /f /q /s
@if exist obj rmdir obj /q /s

cd source\parser
call fxclean
cd ..\output
call fxclean
cd ..\app
call fxclean
cd ..\..



@echo ---------------Finished cleaning Luadbg.-----------------
@echo ************************************************************************
