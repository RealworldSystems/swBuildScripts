# FIXME: inline this somehow into BuildSmallworldImage.rb
ARGV[1] = 'BUILD_IMAGE.cmd'
system({"COMSPEC" => ENV["COMSPEC_OLD"]}, "cmd.exe " + ARGV.join(" "))
