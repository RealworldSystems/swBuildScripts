call smallworld_environment.bat
call build_environment.bat

REM configure the environment for the cambridge product
REM NOTE: this is not needed for all other products, but for now, we maintain a
REM common environment.bat for all products
set CAMBRIDGE_DB_DIR=%SMALLWORLD_GIS%\..\cambridge_db

REM UTRM configuration
REM set GIS, licence, login, and VM settings
set SW_MESSAGE_DB_DIR=\\files3\Software\smallworld\Gis420\product\data

set MEM_PARAMS=-Mnew 64M -Mold 32M -Mpage 32M -Mext 512M
set ARGS=-no_interactive -login root %MEM_PARAMS%

REM configure test database
set SW_ACE_DB_DIR=\\files3\Projects\ut\smallworld\420\cambridge_db\ds\ds_admin

REM configure testrunner
SET ROOS_TESTRUNNER_DB_DIR=\\files3\Projects\UT\smallworld\Salzburg\TR_LA_MUnit\ds_testrunner
SET AUTOMATIC_CONFIG_DIR=%PROJECT_DIR%\config
SET AUTOMATIC_REPORT_DIR=%PROJECT_DIR%\log\tests

REM TODO: move this out of the 'static' environment.bat, so it can be overriden by our Rakefile
REM configure IDE
set EMACSROOT=c:\rwemacslt
REM this is the correct location for RealMacsLt, however, this is broken atm
REM due to spaces in the pathname
REM set EMACSROOT=s:\Realworld Emacs LT
