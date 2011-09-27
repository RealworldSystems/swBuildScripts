
# rake/clean is required below, so we can override the docs
require 'YAML'
require 'file/tail'
require 'erb'

## ###########################################################################
# Definition of the Smallworld Image task

# Declare a Smallworld Image
#
# Example:
#   smallworld_image :open => :closed do
#     puts "Doing a task with the open image"
#   end
#
def smallworld_image(*args, &block)
  Smallworld::Image.define_smallworld_image(*args, &block)
end

module Smallworld

  module BUILD
    DIRS = %w[ images log log/tests ]
    DIRS.each {|d| directory d}
  end

  # This returns the GIS command for launching Smallworld.
  #
  module_function
  def gis_cmd
    File.join %W( #{SW_ENVIRONMENT['SMALLWORLD_GIS']} bin x86 gis.exe )
  end

  # Start a Smallworld GIS with the given arguments, and the environment.bat
  # from the current working dir.
  #
  module_function
  def start_gis(*args)
    if not File.exists?(gis_cmd)
      fail "FATAL: unable to start gis.exe, file not found or available (full path: #{gis_cmd})"
    end
    system SW_ENVIRONMENT, gis_cmd, *%W[ -e #{File.absolute_path("environment.bat")} ] + args
  end

  # Start a Smallworld GIS (similar to +Smallworld::start_gis+), and redirect
  # standard input and output (input to NUL, output to log\start_gis.log).
  #
  module_function
  def start_gis_redirect(args)
    start_gis *%w[ -l log\start_gis.log ], args, :in => 'NUL'
  end

  class Image < Rake::Task

    include BUILD

    # These are class methods.
    #
    class << self

      # Define a +smallworld_image+, just like +Rake::define_task+ defines a
      # task.
      #
      def define_smallworld_image(*args, &block)
        image = Rake.application.define_task(self, *args, &block)
        image.register_tasks(&block)
        image.clear_comment
        image
      end
    end

    # Clears the comment for the pseudo task +Smallworld::Image+, so it won't
    # show up in the list of runnable tasks.
    #
    def clear_comment
      @comment = nil
    end

    # File name of this image.  Returns a +String+ depicting the relative path
    # of the image.
    #
    def file_name
      "images/#{@name}.msf"
    end

    # Log file that Smallworld creates when building an image.  Returns a
    # +String+ depicting the relative path of the image.
    #
    def log_file
      "log/main/#{@name}.log"
    end

    # The base image for this image. This takes the first dependency of this
    # task, since an image will always have a single image as dependency.
    # Returns the dependent +Smallworld::Image+.
    #
    def base_image
      Rake::Task[@prerequisites[0]] rescue nil
    end

    # Registers a build, start and clean task for this image, all in the image's
    # namespace.
    #
    def register_tasks(&block)
      namespace(@name) do |ns|

        file file_name => BUILD::DIRS + [(base_image.file_name rescue nil)].compact do
          rm_f log_file
          puts "Building #{@full_comment} image"
          run_build
        end

        desc "Build a #{@full_comment} image"
        task :build => file_name

        desc "Start a #{@full_comment} image"
        task :start => file_name do
          puts "Starting #{@full_comment} image"
          Smallworld.start_gis @name
        end

        desc "Run unit tests for #{@full_comment} image"
        task :test => :build do
          puts "Starting unit tests for #{@full_comment} image"

          exit_code, output_contains_errors = run_script(@name, 'config\magik_images\source\run_tests.magik')

          fail "running tests failed: gis.exe returned #{$?.exitstatus}" if exit_code != 0
          fail "running tests failed: encountered '#{error_seq}' sequence in the logfile" if output_contains_errors
        end

        desc "Run a script with #{@full_comment} image"
        task :run_script => :build do

          script_file = ENV['RUN_SCRIPT']
          fail "#{@name}:run: set environment variable RUN_SCRIPT to the appropriate file" if not script_file
          fail "#{@name}:run: '#{script_file}' does not exist" if not File.exists?(script_file)

          puts "Running script '#{script_file}' for image #{@full_comment}"
          exit_code, output_contains_errors = run_script(@name, script_file)

          fail "running the script failed: gis.exe returned #{$?.exitstatus}" if exit_code != 0
          fail "running the script failed: encountered '#{error_seq}' sequence in the logfile" if output_contains_errors
        end

        desc "Remove the image for #{@full_comment}"
        task :clean do
          rm_f [file_name, log_file]
        end

        ns.tasks.each do |task|
          task.enhance(&block) if block_given?
        end

      end
    end

  end
  
  module BUILD

    # Builds the given Smallworld image, redirects the build logfile to std out and
    # filters all unwanted lines.
    #
    def run_build

      redirect_logfile_to_console(log_file) do |line|
        puts line if not skip_line? line
      end

      Smallworld.start_gis_redirect "build_#{@name}"

      stop_redirection
      fail "build failed: encountered '#{error_seq}' sequence in the logfile" if output_contains_errors?
      fail "build failed: gis.exe returned #{$?.exitstatus}" if $?.exitstatus != 0
    end

    # Runs the given script for the current image.  Doesn't check if the script
    # file exists. Returns the exit code and, if the output contains any errors, according to the
    # Smallworld error sequence (+error_seq+).
    #
    module_function
    def run_script (image_name, script)
      start_gis_cmd = %W[ #{Smallworld.gis_cmd} -e #{File.absolute_path("environment.bat")} #{image_name} ]
      cmd = [SW_ENVIRONMENT] + start_gis_cmd + [:in => script]

      output_contains_errors = false
      IO.popen cmd do |file|
        file.each do |line|
          puts line if not skip_line? line
          output_contains_errors = true if line.index(error_seq)
        end
      end
      [$?.exitstatus, output_contains_errors]
    end

    # Simulates redirection of the given file, by tailing the file to the
    # console.
    #
    def redirect_logfile_to_console(file)
      Thread.abort_on_exception = true
      @output_log_thread = Thread.start do

        until File.exists?(file)
          sleep 1
        end

        File::Tail::Logfile.open(file) do |log|
          log.tail do |line|
            if block_given?
              yield line
            else
              puts line
            end
          end
        end
      end
    end

    # Kill the redirection thread.
    #
    def stop_redirection
      # we use a regular sleep, since a lock is acquired immediately, and the
      # output is still lost
      sleep 1
      @output_log_thread.kill
    end

    # Applies all filters to the line to check if it should be skipped.
    # Disabled if rake is invoke with the trace flag.
    #
    module_function
    def skip_line?(line)
      return false if Rake::application.options.trace

      user_filters = OUTPUT_FILTERS rescue []
      (DEFAULT_FILTERS + user_filters).each do |filter|
        return true if line =~ filter
      end
      false
    end

    # The standard Smallworld error sequence.
    #
    def error_seq
      '**** Error: '
    end

    # Checks the logfile for the error sequence, fails if present.
    #
    def output_contains_errors?

      File.open(log_file).each do |line|
        return true if line.index(error_seq)
      end
      nil
    end

    DEFAULT_FILTERS = [
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

  end

  # Loads the give YAML encoded config file +f+, and processes it using ERB.
  #
  def load_config_file(f)
    YAML.load(ERB.new(File.read(f)).result)
  end

  # Load the config environment.yaml, and if present, the user override config
  # file my_environment.yaml. Processes both files using ERB, so both files can
  # contain ruby code.
  #
  def load_config
    config_file = 'environment.yaml'
    user_config_file = 'my_environment.yaml'

    config = load_config_file(config_file)
    config.merge! load_config_file(user_config_file) if File.exists?(user_config_file)
    config
  end

end # module Smallworld

################################################################################
# default build targets (CLEAN and EMACS), and retrieval of the environment
 
# First define the documentation for these tasks, before requiring the clean
# library, since the require statement will define these tasks with a default
# description, which cannot be overriden.
desc "Remove images and logfiles."
task :clean

desc "Remove generated bytecode files (magikc and msgc)."
task :clobber
require 'rake/clean'
CLEAN.include(Smallworld::BUILD::DIRS)
CLEAN.include("start_gis.log")

CLOBBER.include("**/*.magikc")
CLOBBER.include("**/*.msgc")

desc "Start emacs"
task :emacs do
  Smallworld.start_gis *%w[ emacs -l bin\share\configure_realmacs.el ]
end

SW_ENVIRONMENT = Smallworld::load_config

# vim:set tw=80 ts=2 sts=2 sw=2 et:
