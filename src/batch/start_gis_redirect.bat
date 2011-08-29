@call %~dp0gis_environment.bat
@call %~dp0project_environment.bat
@%gis% -e environment.bat -l start_gis.log %* <NUL
