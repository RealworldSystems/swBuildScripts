require 'rake/clean'
require 'YAML'
require 'file/tail'

module BUILD
  Dirs = %w[ images log ]
end
BUILD::Dirs.each {|d| directory d}

# TODO: change the descriptions of these tasks, so the user knowns what they
# actually mean.

# we use the exact opposite notions of clean and clobber, since we don't want
# to remove the intermediate files (magikc files), but we do want to kill the images
CLEAN.include(BUILD::Dirs)
CLEAN.include("start_gis.log")

CLOBBER.include(FileList['**/*.magikc'])
CLOBBER.include(FileList['**/*.msgc'])

class Image
  attr_reader :name, :description, :base_image
  def initialize(name, description, base_image)
    @name = name
    @description = description
    @base_image = base_image
  end
  def to_s()
    "Image: #{@name} (#{@description}), base image: #{@base_image}"
  end
  def file_name
    "images/#{@name}.msf"
  end
end

$default_filters = [
  /^Loading module definition/,
  /^Adding product from/,
  /^Checking : .* for patches to rev : /,
  /^compiling /,
  /^Defining /,
  /^Running something$/,
  /^--- line/,
  /^Module .* is already loaded/,
  /^Loading.*magikc$/,
  /^Loading patches from.*/,
  /^Pragma Monitor: condition.*_method$/,
  /^Loading.*declare_patches.magik$/,
  /^a .*method_finder loading/,
  /^method_finder: loaded$/,
  /^Image updated, Save image if required$/,
  /^Reloading module definition for/,
  /^message_handler/,
  /^Module.*does not have any resources/,
  /^Loading.*\.magik$/,
  /magikc written$/,
  /^loading.*\.msg$/,
  /^generating .*msgc$/,
  /Product .* is already loaded from/,
]

# Checks the logfile for the error sequence, fails if present.
#
def fail_on_error(log_file)
  error_seq = '**** Error: '

  File.open(log_file).each do |line|
    fail "build failed: encountered '#{error_seq}' sequence in the logfile" if line.index(error_seq)
  end
end

# Applies all filters to the line to check if it should be skipped.
#
def skip_line?(line)
	$default_filters.each do |filter|
		return true if line =~ filter
	end
  false
end

# Builds the given Smallworld image, redirects the build logfile to std out and
# filters all unwanted lines.
#
def run_build(image_name)
  log_file = "log/main/#{image_name}.log"
  t = Thread.start do

    sleep 1

    File::Tail::Logfile.open(log_file) do |log|
      log.tail do |line|
        puts line if not skip_line? line
      end
    end

  end

  start_gis_redirect "build_#{image_name}"

  sleep 1
  fail_on_error log_file
  t.kill

  fail "build failed: gis.exe returned #{$?.exitstatus}" if $?.exitstatus != 0
end

def register_image_tasks(image)
  namespace(image.name) do

    base_image_file = image.base_image ? [image.base_image.file_name] : []

    file image.file_name => BUILD::Dirs + base_image_file do
      puts "Building #{image.description} image"
      run_build image.name
    end

    desc "Build a #{image.description} image"
    task :build => image.file_name

    desc "Start a #{image.description} image"
    task :start => image.file_name do
      puts "Starting #{image.description} image"
      start_gis image.name
    end

    desc "Remove the image for #{image.description}"
    task :clean do
      rm_f image.file_name
    end
  end
end

def smallworld_image(name, description, base_image=nil)
  $images[name] = Image.new(name, description, $images[base_image])
  register_image_tasks $images[name]
end

def start_gis(args)
  gis_cmd = File.join %W( #{$sw_environment['SMALLWORLD_GIS']} bin x86 gis.exe )
  system $sw_environment, "#{gis_cmd} -e environment.bat #{args}"
end

def start_gis_redirect(args)
  start_gis "-l log\\start_gis.log #{args} <NUL"
end

def load_config
  config = YAML.load_file('environment.yaml')
  config.merge! YAML.load_file('my_environment.yaml') if File.exists?('my_environment.yaml')
  config
end

def main
  $images = {}
  $sw_environment = load_config
  $sw_environment['PROJECT_DIR'] = File.dirname(__FILE__)
  $sw_environment['SW_GIS_ALIAS_FILES'] = File.absolute_path($sw_environment['SW_GIS_ALIAS_FILES'])

  desc "Start emacs"
  task :emacs do
    start_gis "emacs -l bin\\share\\configure_realmacs.el"
  end
end

main()

# vim:set tw=100 ts=2 sts=2 sw=2 et:
