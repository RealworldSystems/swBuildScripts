require 'rake/packagetask'

version = `git rev-parse --short HEAD`.strip
build_number = ENV['BUILD_NUMBER']
version += "-build#{build_number}" if build_number

pt = Rake::PackageTask.new("swBuildScripts", version) do |p|
  p.need_zip = true
  p.package_files.include %w( src/**/* examples/**/* )
  p.package_files.exclude /common/
end

# inline {src,examples/batch}/common dirs into its siblings
file pt.package_dir_path do
  %w[ src examples/batch ].each do |src|
    FileList.new("#{src}/*").exclude(/common/).each do |dest|
      # FIXME: prevent overwriting existing files (have rake invoke cp_r with "-n" somehow)
      cp_r FileList.new("#{src}/common/**"), File.join(pt.package_dir_path, dest)
    end
  end
end

task :default => :repackage
