REM
REM Smallworld Product Windows Environment
REM
REM This file should not normally need to be edited by hand.
REM In any case, do not add anything other than simple SET, REM and
REM CALL lines, as it is read by the 'gis' command, not just by cmd.exe.
REM Note that the CALL statement can be used to call other batch files.
REM However these have the same restrictions on their contents. Also
REM the gis launcher program limits the CALL stack to be a maximum of 32
REM levels deep.
REM

set SW_PRODUCTS_PATH=%SMALLWORLD_GIS%
set SW_MESSAGE_DB_DIR=%SMALLWORLD_GIS%\data
set SW_GIS_PATTERN_DIR=%SMALLWORLD_GIS%\data\xview_patterns
set SW_FONT_PATH=%SMALLWORLD_GIS%\data\vecfonts
set SW_FONT_CONFIG=%SMALLWORLD_GIS%\config\font\custom;%SMALLWORLD_GIS%\config\font
set SW_FONT_METRICS=%SMALLWORLD_GIS%\config\fontmetrics
set SW_CODE_TABLES=%SMALLWORLD_GIS%\data\code_tables
set SW_GIS_TEMPLATE_DIR=%SMALLWORLD_GIS%\data\template
set SW_GIS_DEFAULT_STYLES_DIR=%SMALLWORLD_GIS%\data\template
set SW_GIS_GLAZIER_DIR=%SMALLWORLD_GIS%\data\glazier
set SW_GIS_DOC_DIR=%SMALLWORLD_GIS%\data\doc
set SW_GIS_PLOT_FILTER_DIR=%SMALLWORLD_GIS%\plotters\site_specific
set SW_MDB_TRANSPORTS=tcpip
set SW_MDB_KEEPALIVE=60,10
set SW_COMPONENT_PATH=%SMALLWORLD_GIS%\source
set SW_ACP_PATH=%SMALLWORLD_GIS%\etc\%PROCESSOR_ARCHITECTURE%
set PATH=%SMALLWORLD_GIS%\bin\%PROCESSOR_ARCHITECTURE%;%PATH%
set EMACSROOT=%SMALLWORLD_GIS%\..\emacs
