require 'open3'
require 'optparse'

require_relative 'polarity_tagger/version'
require_relative 'polarity_tagger/option_parser'

module Opener
  ##
  # Ruby wrapper around the Python polarity tagger.
  #
  # @!attribute [r] args
  #  @return [Array]
  # @!attribute [r] options
  #  @return [Hash]
  # @!attribute [r] option_parser
  #  @return [OptionParser]
  #
  class PolarityTagger
    attr_reader :args, :options, :option_parser

    ##
    # @param [Hash] options
    #
    # @option options [Array] :args The commandline arguments to pass to the
    #  underlying Python script.
    #
    def initialize(options = {})
      @args          = options.delete(:args) || []
      @options       = options
      @option_parser = OptionParser.new
    end

    ##
    # Builds the command used to execute the kernel.
    #
    # @return [String]
    #
    def command
      return "python -E -O #{kernel} #{args.join(' ')}"
    end

    ##
    # Runs the command and returns the output of STDOUT, STDERR and the process
    # information.
    #
    # @param [String] input The input to process.
    # @return [Array]
    #
    def run(input)
      option_parser.parse(args)

      if !input or input.empty?
        option_parser.show_help
      end

      return Open3.capture3(command, :stdin_data => input)
    end

    protected

    ##
    # @return [String]
    #
    def core_dir
      return File.expand_path('../../../core', __FILE__)
    end

    ##
    # @return [String]
    #
    def kernel
      return File.join(core_dir, 'poltagger-basic-multi.py')
    end
  end # PolarityTagger
end # Opener
