require 'rake/packagetask'

pt = Rake::PackageTask.new("swBuildScripts", :noversion) do |p|
    p.need_zip = true
    p.package_files.include %w( src/**/* examples/**/* )
    p.package_files.exclude /common/
end

# add src/common/** to src/{batch,rake}
file pt.package_dir_path do
	%w[ src/batch src/rake ].each do |dest|
		cp_r FileList.new("src/common/**"), File.join(pt.package_dir_path, dest)
	end
end

task :default => :repackage
