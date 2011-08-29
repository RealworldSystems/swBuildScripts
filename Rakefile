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
      dest_d = File.join(pt.package_dir_path, dest)
      # NOTE: we don't want to override existing files, so we can't use cp_r
      # (no support for a non-overwrite switch :S). Hence, we need to manually
      # do the recursive copy
      FileList.new("#{src}/common/**").each do |source_f|
        if File.directory?(source_f)
          mkdir_p(File.join(dest_d, source_f.gsub(/common/, "")))
        else
          safe_ln source_f, dest_d unless File.exist?(File.join(dest_d, File.basename(source_f)))
        end
      end
    end
  end
end

task :default => :repackage
