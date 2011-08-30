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
  %w[ src examples/batch ].each do |common_parent|
    FileList.new("#{common_parent}/*").exclude(/common/).each do |common_sibling|
      # NOTE: we don't want to override existing files, so we can't use cp_r
      # (no support for a non-overwrite switch :S). Hence, we need to manually
      # do the recursive copy
      FileList.new("#{common_parent}/common/**/*").each do |source_f|
        common_d = File.join(common_parent, "common")
        dest_f = File.join(pt.package_dir_path, common_sibling, source_f[common_d.length..-1])
        if File.directory?(source_f)
          mkdir_p(dest_f)
        else
          safe_ln source_f, File.dirname(dest_f) unless File.exist?(dest_f)
        end
      end
    end
  end
end

task :default => :repackage
