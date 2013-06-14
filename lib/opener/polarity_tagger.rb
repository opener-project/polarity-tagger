require 'open3'
require 'optparse'

require_relative 'polarity_tagger/version'
require_relative 'polarity_tagger/cli'

module Opener
  ##
  # Ruby wrapper around the Python based polarity tagger.
  #
  # @!attribute [r] options
  #  @return [Hash]
  #
  class PolarityTagger
    attr_reader :options

    ##
    # Hash containing the default options to use.
    #
    # @return [Hash]
    #
    DEFAULT_OPTIONS = {
      :args => []
    }.freeze

    ##
    # @param [Hash] options
    #
    # @option options [Array] :args Collection of arbitrary arguments to pass
    #  to the underlying kernel.
    #
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
    end

    ##
    # Returns a String containing the command to use for executing the kernel.
    #
    # @return [String]
    #
    def command
      return "python -E -O #{kernel} #{options[:args].join(' ')}"
    end

    ##
    # Processes the input and returns an Array containing the output of STDOUT,
    # STDERR and an object containing process information.
    #
    # @param [String] input The text of which to detect the language.
    # @return [Array]
    #
    def run(input)
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
