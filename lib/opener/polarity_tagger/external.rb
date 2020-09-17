module Opener
  class PolarityTagger
    ##
    # Ruby wrapper around the Python based polarity tagger.
    #
    # @!attribute [r] options
    #  @return [Hash]
    #
    # @!attribute [r] args
    #  @return [Array]
    #
    class External

      attr_reader :options, :args

      ##
      # @param [Hash] options
      #
      # @option options [Array] :args Collection of arbitrary arguments to pass
      #  to the underlying kernel.
      #
      # @option options [String] :resource_path Path to the lexicons to use.
      #
      def initialize options = {}
        @args    = options.delete(:args) || []
        @options = options
      end

      ##
      # Returns a String containing the command to use for executing the kernel.
      #
      # @return [String]
      #
      def command
        return "#{adjust_python_path} python -E #{kernel} #{lexicon_path} #{args.join(" ")}"
      end

      ##
      # @return [String]
      #
      def lexicon_path
        path = options[:resource_path] || ENV['RESOURCE_PATH'] ||
          ENV['POLARITY_LEXICON_PATH']

        return path ? "--lexicon-path #{path}" : nil
      end

      ##
      # Processes the input and returns an Array containing the output of STDOUT,
      # STDERR and an object containing process information.
      #
      # @param [String] input The text of which to detect the language.
      # @return [Array]
      #
      def run(input)
        stdout, stderr, process = capture(input)

        raise stderr unless process.success?
        puts stderr if ENV['DEBUG']

        return stdout
      end

      protected

      ##
      # @return [String]
      #
      def adjust_python_path
        site_packages =  File.join(core_dir, 'site-packages')

        "env PYTHONPATH=#{site_packages}:$PYTHONPATH"
      end

      ##
      # capture3 method doesn't work properly with Jruby, so
      # this is a workaround
      #
      def capture(input)
        Open3.popen3(*command.split(" ")) {|i, o, e, t|
          out_reader = Thread.new { o.read }
          err_reader = Thread.new { e.read }
          i.write input
          i.close
          [out_reader.value, err_reader.value, t.value]
        }
      end

      ##
      # @return [String]
      #
      def core_dir
        File.expand_path '../../../../core', __FILE__
      end

      ##
      # @return [String]
      #
      def kernel
        File.join core_dir, 'poltagger-basic-multi.py'
      end

    end
  end
end
