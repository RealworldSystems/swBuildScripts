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
  %w[ src examples examples/batch ].each do |common_parent|
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

%w[ cambridge munit cdh utrm ].each do |project|
  namespace(project) do
    %w[ batch rake ].each do |product|
      namespace(product) do

        sources = %W(
          #{pt.package_dir_path}/src/#{product}
          #{pt.package_dir_path}/examples/#{product}/#{project}
        )
        dest_d = ".."

        desc "Install the #{product} files for #{project}"
        task :install => :package do

          sources.each do |source_dir|
            FileList.new("#{source_dir}/**/*").each do |source_f|
              dest_f = File.join(dest_d, source_f[source_dir.length..-1])
              if File.directory?(source_f)
                mkdir_p(dest_f)
              else
                rm_f dest_f
                safe_ln source_f, File.dirname(dest_f)
              end
            end
          end
        end

        desc "Remove all installed files for the #{product} files for #{project}"
        task :remove => :package do
          sources.each do |source_dir|
            FileList.new("#{source_dir}/*").each do |source_f|
              dest_f = File.join(dest_d, source_f[source_dir.length..-1])
              rm_rf dest_f
            end
          end
        end

      end
    end
  end
end

task :default => :repackage
