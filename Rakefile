require './Rakefile.lib'

# cambridge images
smallworld_image :cam_db_closed_swaf, "closed cambridge"
smallworld_image :cam_db_open_swaf, "open cambridge", :cam_db_closed_swaf

# munit images
smallworld_image :munit_420, "munit 420"
smallworld_image :munit_gui, "munit gui"

# CDH image
smallworld_image :cdh, "CDH"

task :default => "cam_db_open_swaf:build"
