@set PROJECT_DIR=%~dp0
@call %~dp0gis_environment.bat
@call %~dp0project_environment.bat
@%gis% -e environment.bat %*
