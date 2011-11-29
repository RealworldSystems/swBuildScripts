@if not defined ORCA_RUNTIME_PATH set ORCA_RUNTIME_PATH=\\files2\ZiggoSLA2\orca_runtime
@if not defined SW_MESSAGE_DB_DIR set SW_MESSAGE_DB_DIR=\\files3\Software\smallworld\Gis420\product\data
@if not defined gis set gis=%ORCA_RUNTIME_PATH%\sw\product\bin\x86\gis.exe

@:: ORCA upgrade 42, old database
@:: @if not defined SW_ACE_DB_DIR set SW_ACE_DB_DIR=\\172.16.0.25\raid0\data\nasSW01\orca_upgrade42\old_databases\admin_old
@:: @if not defined DS_ROOT set DS_ROOT=\\172.16.0.25\raid0\data\nasSW01\orca_upgrade42\old_databases\ds_old
@:: @if not defined DS_ROOT set DS_ROOT2=\\172.16.0.25\raid0\data\nasSW01\orca_upgrade42\ds_conv

@:: ORCA upgrade 42, new database
@if not defined SW_ACE_DB_DIR set SW_ACE_DB_DIR=\\172.16.0.25\raid0\data\nasSW01\orca_upgrade42\ds\admin
@if not defined DS_ROOT set DS_ROOT=\\172.16.0.25\raid0\data\nasSW01\orca_upgrade42\ds

@:: @if not defined GNR_DB set GNR_DB=\\files2\ZiggoOT\west_dev_test_env\ds\ ;; old path, below is new path
@if not defined GNR_DB set GNR_DB=\\172.16.0.61\raid0\data\SLOWSTORAGE\ORCADBs\westmigration_ds_200912\ds

@if not defined ROOS_TYPE_IMAGES set ROOS_TYPE_IMAGES=\\realworld\data\ZiggoOT\work_source\FrontView

@:: -----------------------------
@:: Environment differentiation (acc, prd, tst)
@:: -----------------------------
@if not defined APPLICATION_ENVIRONMENT set APPLICATION_ENVIRONMENT=prd

@if not defined EMACSROOT set EMACSROOT=%ProgramFiles%\Realworld Emacs LT
