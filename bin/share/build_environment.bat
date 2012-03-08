set PROJECT_DIR=%~dp0..\..

set PATH=%PATH%;%PROJECT_DIR%\bin\share
set gis=runalias.exe

set SW_GIS_ALIAS_FILES=%PROJECT_DIR%\config\magik_images\resources\base\data\gis_aliases
set LOG_DIR=%PROJECT_DIR%\log
set SW_SAVE_IMAGE_DIR=%PROJECT_DIR%\images
set SW_SAVE_IMAGE_DIR_FORMAT=spin
set SPIN=main

:: sw binaries are always located in the x86 path, so overrule it
set PROCESSOR_ARCHITECTURE=x86
