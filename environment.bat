call %PROJECT_DIR%\smallworld_environment.bat
call %PROJECT_DIR%\config\version.bat

set ORCA_ROOT=%PROJECT_DIR%

REM -------------------------------------------------------------------
REM Customer specific settings here, changes here should not be needed!
REM -------------------------------------------------------------------

set SW_LANGUAGE=nl_nl;en_gb
set SW_TZ=Europe/Amsterdam

REM -------------------------------------------------
REM In case we start using a short transaction server
REM -------------------------------------------------
set ORCA_STS_HOST=localhost
set ORCA_STS_PORT=3011

REM -----------
REM SW Products
REM -----------

set SW_NEN1878_TEMP_DIR=%TEMP%
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%SMALLWORLD_GIS%\..\soms420
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%SMALLWORLD_GIS%\..\dxf420
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%SMALLWORLD_GIS%\..\NEN1878
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%SMALLWORLD_GIS%\..\nbl

REM -------------
REM ORCA products
REM -------------
set RCA_ROOT=%ORCA_ROOT%
set RCA_TEMPLATES_DIR=%ORCA_ROOT%\config\templates
REM set SNA_ROOT=%ORCA_ROOT%\SNA
REM set RCA_SOURCE_ROOT=%ORCA_ROOT%\modules\Core
REM set SNA_SOURCE_ROOT=%ORCA_ROOT%\modules\Custom
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%RCA_SOURCE_ROOT%
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%SNA_SOURCE_ROOT%
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%ORCA_RUNTIME_DIR%\realworld_modules
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%RCA_SOURCE_ROOT%\roos_projectware
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%SNA_SOURCE_ROOT%\locally_supported
REM set SW_PRODUCTS_PATH=%SW_PRODUCTS_PATH%;%ORCA_ROOT%\sw\SyncManager\roos_sync_manager
set MIGRATION_PRODUCT_PATH=\\realworld\data\projects\UT\orca\devenv\app\MigrationNorth
REM ToDo: This Fixes mechanism needs to go, we use decent patches in source\release_patches
set FIXES=%ORCA_ROOT%\SNA\sw_site_specific\fixes
set SW_FONT_CONFIG=%ORCA_ROOT%\config\font\custom;%SW_FONT_CONFIG%
set SW_GIS_PLOT_FILTER_DIR=%ORCA_ROOT%\config\plotters
set ORCA_LOG_DIR=%LOG_DIR%
set SW_MDB_COMPRESS_DISABLE=TRUE
set ORCA_ADMIN_DIR=%ORCA_ROOT%\config\templates\xml_user_interfaces\roos_migration_framework
set ROOS_MIGRATION_TOP_DIR=C:\Temp\migration
set ROOS_MIGRATION_LOG_DIR=%LOG_DIR%\migration
set ROOS_CRAMER_EXPORT_LOG_DIR=%LOG_DIR%\cramer_export_log
REM ----
REM Next variable is ;-divided
set MIGRATION_FILE_ALTERNATIVE_PATH=\\Rwxp88\Migration_file_ds;\\Rwxp88\Proef_migratie;\\Rwxp88\Proef_migratie_isp
REM ----
set system_session_xml_dir=%ORCA_ROOT%\config\templates\xml_user_interfaces

REM -----------------------------
REM KLIC related
REM -----------------------------
set ROOS_KLIC_DIR=%ORCA_ROOT%\data\klic

REM --------
REM Database
REM --------

set RCA_GIS_DB_DIR=%DS_ROOT%\gis
set RCA_TYPE_DB_DIR=%DS_ROOT%\type
set RCA_TOPO_DB_DIR=%DS_ROOT%\topo
set RCA_SCHEMATICS_DB_DIR=%DS_ROOT%\schematics
set RCA_CONV_DB_DIR=%DS_ROOT%\conversion
set RCA_DXF_DATA_DB_DIR=%RCA_CONV_DB_DIR%
set ROOS_RELATED_DOCS=%DS_ROOT%\docs

REM -----------------------------
REM Subjects of potential changes 
REM -----------------------------



REM -----------------------------
REM Orca Patch Loader (OPL) 
REM -----------------------------

set OPL_TEMP_PATCH_DIR=%ORCA_ROOT%\opl_patches
set OPL_DYN_PATCH_DIR=%ORCA_ROOT%\orca_dynamic_patches\source\release_patches

REM -----------------------------
REM For Post Processing Environment
REM -----------------------------
set POST_PROCESSING_WEST_PATH=%ORCA_ROOT%\..\WestMigration\PostProcessingWest

REM -----------------------------
REM BUILD configuration
REM -----------------------------
set ROOS_DISABLE_AUTH_DURING_OPENING_DATABASE=true
