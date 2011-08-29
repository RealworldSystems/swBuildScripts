require 'rake/packagetask'

version = `git rev-parse --short HEAD`.strip
build_number = ENV['BUILD_NUMBER']
version += "-build#{build_number}" if build_number

pt = Rake::PackageTask.new("swBuildScripts", version) do |p|
    p.need_zip = true
    p.package_files.include %w( src/**/* examples/**/* )
    p.package_files.exclude /common/
end

# TODO: refactor next two entries into one

# add src/common/** to src/{batch,rake}
file pt.package_dir_path do
	%w[ src/batch src/rake ].each do |dest|
		cp_r FileList.new("src/common/**"), File.join(pt.package_dir_path, dest)
	end
end

# add examples/common/** to examples/{cambridge,munit,cdh,utrm}
file pt.package_dir_path do
	%w[ examples/batch/cambridge examples/batch/munit examples/batch/cdh examples/batch/utrm ].each do |dest|
		cp_r FileList.new("examples/batch/common/**"), File.join(pt.package_dir_path, dest)
	end
end

task :default => :repackage
