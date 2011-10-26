@echo off
call %~dp0build_environment.bat
call %PROJECT_DIR%project_environment.bat
if exist %PROJECT_DIR%my_project_environment.bat call %PROJECT_DIR%my_project_environment.bat
%gis% -e environment.bat %*
