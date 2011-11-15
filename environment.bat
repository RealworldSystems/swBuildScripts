call %PROJECT_DIR%\smallworld_environment.bat

set MEM_PARAMS=-Mnew 64M -Mold 32M -Mpage 32M -Mext 512M
set ARGS=-cli -no_interactive -login root %MEM_PARAMS%
