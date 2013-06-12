module Opener
  class PolarityTagger
    ##
    # Configures the CLI options for the base tagger using OptionParser.
    #
    # @!attribute [r] parser
    #  @return [OptionParser]
    # @!attribute [r] options
    #  @return [Hash]
    #
    class OptionParser
      attr_reader :parser, :options

      def initialize
        @options = default_options
        @parser  = ::OptionParser.new do |opts|
          opts.banner = 'Usage: cat input_file.kaf ' \
            '| polarity-tagger [OPTIONS]'

          opts.on('-h', '--help', 'Shows this help message') do
            show_help
          end

          opts.on('-v', '--version', 'Shows the version') do
            puts "polarity-tagger v#{VERSION} #{RUBY_DESCRIPTION}"
            exit
          end

          opts.on('-l', '--log', 'Enable logging to STDERR') do
            @options[:logging] = true
          end
        end
      end

      ##
      # Convenience method for parsing options without having to include
      # `.parser` in the call chain.
      #
      def parse(*args)
        return parser.parse(*args)
      end

      ##
      # Shows the help message and aborts.
      #
      def show_help
        abort parser.to_s
      end

      ##
      # @return [Hash]
      #
      def default_options
        return {:logging => false}
      end

      ##
      # @return [TrueClass|FalseClass]
      #
      def logging?
        return options[:logging] == true
      end
    end # OptionParser
  end # PolarirtyTagger
end # Opener
