require_relative 'bin/share/BuildSmallworldImage'

desc "munit for Smallworld 420"
smallworld_image :munit_420

desc "actual image name flushed out by munit_420"
smallworld_image :munit_gui

task :move_munit do
  FileList['munit/*'].each do |f|
    mv f, '.'
  end
end

task :default => [:move_munit, "munit_420:build"] do

  # enable testing, and set the product to test
  ENV['RUN_SCRIPT'] = 'bin/share/testing.magik'
  ENV['UNIT_TEST_PRODUCT'] = 'munit'

  Rake::Task["munit_gui:run_script"].invoke
end
