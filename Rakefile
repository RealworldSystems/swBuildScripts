require_relative 'bin/share/BuildSmallworldImage'

desc "ORCA tools"
smallworld_image :orca_tools

desc "runtime image, with all required software from $ORCA_RUNTIME_PATH"
smallworld_image :runtime

desc "ORCA swaf"
smallworld_image :orca_swaf => :runtime

desc "ORCA closed"
smallworld_image :orca_closed => :orca_swaf

desc "ORCA custom closed"
smallworld_image :orca_custom_closed => :orca_closed

desc "ORCA custom open"
smallworld_image :orca_custom_open => :orca_custom_closed

task :default => "orca_custom_open:build"
