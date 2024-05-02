



pip check
IF %ERRORLEVEL% NEQ 0 exit /B 1
nosetests --help
IF %ERRORLEVEL% NEQ 0 exit /B 1
exit /B 0
