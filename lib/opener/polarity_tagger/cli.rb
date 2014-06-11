require 'opener/core/resource_switcher'
require 'opener/core/argv_splitter'

module Opener
  class PolarityTagger
    ##
    # CLI wrapper around {Opener::LanguageIdentifier} using OptionParser.
    #
    # @!attribute [r] options
    #  @return [Hash]
    # @!attribute [r] option_parser
    #  @return [OptionParser]
    #
    class CLI
      attr_reader :options, :option_parser, :resource_switcher

      ##
      # @param [Hash] options
      #
      def initialize(options = {})
        @options = options

        @resource_switcher = Opener::Core::ResourceSwitcher.new
        component_options, options[:args] = Opener::Core::ArgvSplitter.split(options[:args])

        @option_parser = OptionParser.new do |opts|
          opts.program_name   = 'polarity-tagger'
          opts.summary_indent = '  '

          resource_switcher.bind(opts, @options)

          opts.on('-h', '--help', 'Shows this help message') do
            show_help
          end

          opts.on('-v', '--version', 'Shows the current version') do
            show_version
          end

          opts.on('-l', '--log', 'Enable logging to STDERR') do
            @options[:logging] = true
          end
        end

        option_parser.parse!(component_options)
        force = false
        resource_switcher.install(@options, force)
      end

      ##
      # @param [String] input
      #
      def run(input)
        tagger = PolarityTagger.new(options)

        stdout, stderr, process = tagger.run(input)

        puts stdout
      end

      private

      ##
      # Shows the help message and exits the program.
      #
      def show_help
        abort option_parser.to_s
      end

      ##
      # Shows the version and exits the program.
      #
      def show_version
        abort "#{option_parser.program_name} v#{VERSION} on #{RUBY_DESCRIPTION}"
      end
    end # CLI
  end # PolarityTagger
end # Opener
