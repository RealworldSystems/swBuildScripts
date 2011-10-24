@echo off
REM For Usage, see BUILD_IMAGE Unix shell script documentation

setlocal
set dir=%SMALLWORLD_GIS%\bin\share\

REM Get arguments: BUILD_IMAGE parent_alias [logfile] [magik_file]
set parent_alias=%1
set logfile=%2
set magik_file=%3
set title=magik_image: %SW_MAGIK_IMAGE_NAME%
set gis=gis.exe

REM Process default values for arguments
if "%logfile%"    == "" set logfile=%SW_MAGIK_IMAGE_NAME%.log
if "%magik_file%" == "" set magik_file=BUILD_IMAGE.magik

REM Determine the directory to store the log file in.
set logdir=logs
if not "%SW_SAVE_IMAGE_DIR%" == "" set logdir=%SW_SAVE_IMAGE_DIR%
if not "%LOG_DIR%"           == "" set logdir=%LOG_DIR%

set logsubdir=.
if "%SW_SAVE_IMAGE_DIR_FORMAT%" == "spin" (
    set logsubdir=%SPIN%
)

if "%SW_SAVE_IMAGE_DIR_DATE_FORMAT%" == "date" (
    for /f "usebackq tokens=*" %%f in (`swfmttime -delimiter # "%SW_SAVE_IMAGE_DIR_DATE_FORMAT%"`) do set logsubdir=%%f
)

REM Create log directory if not present already, create any intermediate directories too
set logdir=%logdir%\%logsubdir%
REM replace / with \ in log directory path
set logdir=%logdir:/=\%
if not exist "%logdir%" (
    echo "Creating Log directory: %logdir%"
    mkdir "%logdir%"
)

REM Run gis command with appropriate input and output redirection
set output=%logdir%\%logfile%
REM replace / with \ in output file
set output=%output:/=\%

set input=%dir%%magik_file%

REM echo %gis% -l "%output%" -i -q %parent_alias% -noinit ^< "%input%"
rem pause

%gis% %parent_alias% -noinit < "%input%"
REM echo EXIT CODE from %1 is %ERRORLEVEL%
rem pause

rem if "%ERRORLEVEL%" == "0" (
rem 	echo "Checking for Errors in log file %output%" 
rem 	findstr /C:"*** Error" "$output"
rem 	if "%ERRORLEVEL%" == "0" (
rem 	    # findstr has zero exit status when strings match.
rem 	    set ERRORLEVEL=1
rem 	)
rem 
rem 	echo Log file check status %ERRORLEVEL%
rem )


endlocal
REM echo EXIT CODE from %1 is %ERRORLEVEL%
exit %ERRORLEVEL%

