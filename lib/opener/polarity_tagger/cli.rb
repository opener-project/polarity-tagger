require 'opener/core'

module Opener
  class PolarityTagger
    ##
    # CLI wrapper around {Opener::LanguageIdentifier} using Slop.
    #
    # @!attribute [r] parser
    #  @return [Slop]
    #
    class CLI
      attr_reader :parser

      def initialize
        @parser = configure_slop
      end

      ##
      # @param [Array] argv
      #
      def run(argv = ARGV)
        parser.parse(argv)
      end

      ##
      # @return [Slop]
      #
      def configure_slop
        Slop.new strict: false, indent: 2, help: true do
          banner 'Usage: polarity-tagger [OPTIONS] -- [PYTHON OPTIONS]'

          separator <<-EOF.chomp

About:

    Component for tagging the polarity of elements in a KAF document. This
    command reads input from STDIN.

Examples:

    Processing a KAF file:

        cat some_file.kaf | polarity-tagger

    Displaying the underlying kernel options:

        polarity-tagger -- --help

          EOF

          separator "\nOptions:\n"

          on :v, :version, 'Shows the current version' do
            abort "polarity-tagger v#{VERSION} on #{RUBY_DESCRIPTION}"
          end

          run do |opts, args|
            tagger = PolarityTagger.new(:args => args)
            input  = STDIN.tty? ? nil : STDIN.read

            puts tagger.run(input)
          end
        end
      end

    end
  end
end
