
# rake/clean is required below, so we can override the docs

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

    extend Rake::DSL rescue nil

    DIRS = %w[ images log log/tests ]
    DIRS.each {|d| directory d}
  end

  class Image < Rake::Task

    include BUILD
    include Rake::DSL rescue nil

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
          puts "Building #{@full_comment} image"
          build_image
        end

        desc "Build a #{@full_comment} image"
        task :build => file_name

        desc "Rebuild a #{@full_comment} image"
        task :rebuild do
          Rake::Task["#{@name}:clean"].invoke
          Rake::Task[file_name].invoke
        end

        desc "Start a #{@full_comment} image"
        task :start => file_name do
          puts "Starting #{@full_comment} image"
          Smallworld.start_gis @name
        end

        desc "Run unit tests for #{@full_comment} image"
        task :test => :build do
          puts "Starting unit tests for #{@full_comment} image"

          test_image = self.clone

          test_image.listeners = [el = ErrorListener.new]
          test_image.filters = [IgnoreOutputFilter.new] if not Rake::application.options.trace

          exit_code = test_image.run @name, 'config\magik_images\source\run_tests.magik'

          fail "running tests failed: encountered '#{ErrorListener::ERROR_SEQUENCE}' sequence in the logfile" if el.error?
          fail "running tests failed: gis.exe returned #{exit_code}" if exit_code != 0
        end

        desc "Run a script with #{@full_comment} image"
        task :run_script => :build do

          script_file = ENV['RUN_SCRIPT']
          fail "#{@name}:run: set environment variable RUN_SCRIPT to the appropriate file" if not script_file
          fail "#{@name}:run: '#{script_file}' does not exist" if not File.exists?(script_file)

          run_image = self.clone

          run_image.listeners = [el = ErrorListener.new]
          run_image.filters = [IgnoreOutputFilter.new] if not Rake::application.options.trace

          puts "Running script '#{script_file}' for image #{@full_comment}"
          exit_code = run_image.run @name, script_file

          fail "running the script failed: encountered '#{ErrorListener::ERROR_SEQUENCE}' sequence in the logfile" if el.error?
          fail "running the script failed: gis.exe returned #{exit_code}" if exit_code != 0
        end

        desc "Remove the image for #{@full_comment}"
        task :clean do
          rm_f file_name
        end

        ns.tasks.each do |task|
          task.enhance(&block) if block_given?
        end

      end
    end

  end

  # Start a Smallworld GIS with the given arguments. Uses the start_gis.bat
  # batch script for loading the project environment and friends.
  #
  module_function
  def start_gis(args)
    system "start_gis.bat #{args}"
  end

  module BUILD

    attr_accessor :env, :filters, :listeners

    def listeners &block
      @listeners.each &block if @listeners
    end

    def filters &block
      @filters.each &block if @filters
    end

    # Builds the given Smallworld image.
    #
    def build_image

      build_image = self.clone

      build_image.listeners = [el = ErrorListener.new, $ll = LogfileListener.new("build_#{@name}"), BuildProfilerListener.new]
      build_image.filters = [IgnoreOutputFilter.new, OutputTimestamperFilter.new] if not Rake::application.options.trace

      # This "COMSPEC hack" prevents Windows from spawning a new command prompt
      # by gis.exe, which looses the standard IO files. When Ruby does this, the
      # standard IO files are preserved. Rubyw is required, since that runs in
      # the "UI subsystem", as opposed to cmd.exe. Running rubyw.exe doesn't
      # trigger the console creation of Windows.
      build_image.env = {
        'COMSPEC_OLD' => ENV['COMSPEC'],
        'COMSPEC' => 'rubyw bin/share/redirect_output.rb',
      }
      exit_code = build_image.run "build_#{@name}"

      fail "build failed: encountered '#{ErrorListener::ERROR_SEQUENCE}' sequence in the logfile" if el.error?
      fail "build failed: gis.exe returned #{exit_code}" if exit_code != 0
    end

    # Runs the given script for the current image.  Doesn't check if the script
    # file exists. Returns the exit code and, if the output contains any errors, according to the
    # Smallworld error sequence (+ERROR_SEQUENCE+).
    #
    def run(image_name, stdin='NUL')
      cmd = %W[ start_gis.bat #{image_name} ] << {:in => stdin}
      cmd.unshift @env if @env

      filters { |filter| filter.start_build }
      listeners { |listener| listener.start_build }

      IO.popen cmd do |file|
        file.each do |line|
          listeners do |listener|
            listener.message line
          end

          filtered_msg = line
          filters do |filter|
            filtered_msg = filter.message filtered_msg if filtered_msg
          end
          puts filtered_msg if filtered_msg
        end
      end

      filters { |filter| filter.end_build }
      listeners { |listener| listener.end_build }

      $?.exitstatus
    end

    # This is the most basic implementation of the listener interface. It does
    # nothing.
    #
    class BaseListener
      def start_build; end
      def end_build; end
      def message msg; end
    end

    # This listener detects the Smallworld error sequence +ERROR_SEQUENCE+. If
    # the sequence is present in the stream, then +error?+ method will report
    # that.
    #
    class ErrorListener < BaseListener
      # The standard Smallworld error sequence.
      #
      ERROR_SEQUENCE = '**** Error: '

      def initialize
        @error = false
      end

      # Return if the Smallworld error sequence was detected in the given
      # stream.
      #
      def error?
        @error
      end

      def message msg
        @error = true if msg.index(ERROR_SEQUENCE)
      end
    end

    # This listener pipes the output back into a logfile
    #
    class LogfileListener < BaseListener
      def initialize logfile_name
        @logfile_name = logfile_name
      end

      def start_build
        @logfile = open("log/#{@logfile_name}.log", 'w')
      end

      def end_build
        @logfile.close
      end

      def message msg
        @logfile.write msg
      end
    end

    # This listener profiles the build by keeping time for each build job. It
    # prints the time taken for the job, and total time to stdout.
    #
    class BuildProfilerListener < BaseListener
      @@invoke_time = nil
      def start_build
        @@invoke_time = Time.now if not @@invoke_time
        @start_time = Time.now
      end

      def end_build
        puts "Build duration: #{Time.now - @start_time} s., Total time: #{Time.now - @@invoke_time} s."
      end
    end

    # This filter adds a timestamp to every output line, so the build can be
    # profiled.
    #
    class OutputTimestamperFilter < BaseListener
      def message msg
        Time.now.strftime('[%H:%M:%S] ') + msg
      end
    end

    # Filters the log message using the default filters
    # (+DEFAULT_IGNORE_FILTERS+), and the user supplied filters
    # (+OUTPUT_FILTERS+). If it matches, the message is ignored.
    #
    class IgnoreOutputFilter < BaseListener
      def filters
        if not @filters
          @filters = OUTPUT_FILTERS rescue []
          @filters += DEFAULT_IGNORE_FILTERS
        end
        @filters
      end

      def message msg
        filters.each do |filter|
          return nil if msg =~ filter
        end
        msg
      end

      DEFAULT_IGNORE_FILTERS = [
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

  end # module BUILD

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

CLOBBER.include("**/*.magikc")
CLOBBER.include("**/*.msgc")

desc "Start emacs"
task :emacs do
  Smallworld.start_gis 'emacs -l bin\share\configure_realmacs.el'
end

SW_ENVIRONMENT = {}

# Development tasks
task :dev do
  system 'git clone git@github.com:RealworldSystems/swBuildScripts.git'
  mv 'swBuildScripts/.git', '.'
  rm_rf 'swBuildScripts'
end

task :update do
  commit_msg = 'BUILD: updated swBuildScripts to version'
  sh %Q[ svn ci $(git ls-tree --name-only -r HEAD) -m "#{commit_msg} $(git rev-parse --short HEAD)" ]
end

# vim:set tw=80 ts=2 sts=2 sw=2 et: