require 'rake/clean'
require 'YAML'
require 'file/tail'

module BUILD
	Dirs = %w[ images log ]
end
BUILD::Dirs.each {|d| directory d}
CLEAN.include(BUILD::Dirs)
CLEAN.include("start_gis.log")

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

$filters = [
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

def run_build(image_name)
	# output the build log, filter it along the way according to our list of
	# regex filters, and test for the 'magik' error sequence
	t = Thread.start do
		sleep 1
		File::Tail::Logfile.open("log/main/#{image_name}.log") do |log|
			log.tail do |line|
				skip = false
				$filters.each do |filter|
					skip = true if line =~ filter
				end
				puts line if not skip
			end
		end
	end
	system $sw_environment, "#{$sw_environment['SMALLWORLD_GIS']}\\bin\\x86\\gis.exe -e environment.bat -l log\\start_gis.log build_#{image_name} <NUL"

	# check file for errors
	sleep 1
	File.open("log/main/#{image_name}.log").each do |line|
		fail "build failed: encountered '**** Error: ' sequence in the logfile" if line =~ /^\*\*\*\* Error: /
	end

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
			system $sw_environment, "#{$sw_environment['SMALLWORLD_GIS']}\\bin\\x86\\gis.exe -e environment.bat #{image.name}"
		end
	end
end

def smallworld_image(name, description, base_image=nil)
	$images[name] = Image.new(name, description, $images[base_image])
	register_image_tasks $images[name]
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
		system $sw_environment, "#{$sw_environment['SMALLWORLD_GIS']}\\bin\\x86\\gis.exe -e environment.bat emacs -l bin\\share\\configure_realmacs.el"
	end
end

main()
