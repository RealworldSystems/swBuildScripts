require 'rake/packagetask'
require 'rake/clean'

CLEAN.include("pkg")

Rake::PackageTask.new("swBuildScripts", :noversion) do |p|
    p.need_zip = true
    p.package_files.include("src", "examples")
end

task :default => :package
