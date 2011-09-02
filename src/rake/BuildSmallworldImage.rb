
# rake/clean is required below, so we can override the docs
require 'YAML'
require 'file/tail'

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
    DIRS = %w[ images log ]
    DIRS.each {|d| directory d}
  end

  # Start a Smallworld GIS with the given arguments, and the environment.bat
  # from the current working dir.
  #
  def start_gis(args)
    gis_cmd = File.join %W( #{SW_ENVIRONMENT['SMALLWORLD_GIS']} bin x86 gis.exe )
    system SW_ENVIRONMENT, "#{gis_cmd} -e environment.bat #{args}"
  end
  module_function :start_gis

  # Start a Smallworld GIS (similar to +Smallworld::start_gis+), and redirect
  # standard input and output (input to NUL, output to log\start_gis.log).
  #
  def start_gis_redirect(args)
    start_gis "-l log\\start_gis.log #{args} <NUL"
  end
  module_function :start_gis_redirect

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
        image.register_tasks
        image.clear_comment
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
    def register_tasks
      namespace(@name) do

        file file_name => BUILD::DIRS + [(base_image.file_name rescue nil)].compact do
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

        desc "Remove the image for #{@full_comment}"
        task :clean do
          rm_f [file_name, log_file]
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
end

# First define the documenation for these tasks, before requiring the library,
# we're unable to override it manually.
desc "Remove images and logfiles."
task :clean

desc "Remove generated bytecode files (magikc and msgc)."
task :clobber
require 'rake/clean'
CLEAN.include(Smallworld::BUILD::DIRS)
CLEAN.include("start_gis.log")

CLOBBER.include("**/*.magikc")
CLOBBER.include("**/*.msgc")

def load_config
  config = YAML.load_file('environment.yaml')
  config.merge! YAML.load_file('my_environment.yaml') if File.exists?('my_environment.yaml')
  config
end

SW_ENVIRONMENT = load_config
SW_ENVIRONMENT['PROJECT_DIR'] = File.dirname(__FILE__)
SW_ENVIRONMENT['SW_GIS_ALIAS_FILES'] = File.absolute_path(SW_ENVIRONMENT['SW_GIS_ALIAS_FILES'])

desc "Start emacs"
task :emacs do
  Smallworld.start_gis "emacs -l bin\\share\\configure_realmacs.el"
end

# vim:set tw=80 ts=2 sts=2 sw=2 et:
