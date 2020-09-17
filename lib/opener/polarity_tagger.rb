require 'open3'
require 'opener/core'
require 'nokogiri'
require 'hashie'

require_relative 'polarity_tagger/version'
require_relative 'polarity_tagger/cli'
require_relative 'polarity_tagger/external'

require_relative 'polarity_tagger/internal'

module Opener
  class PolarityTagger

    def initialize options = {}
      @args    = options.delete(:args) || []
      @options = options
      @klass   = if ENV['LEGACY'] then External else Internal end
      @proc    = @klass.new args: @args
    end

    def run input
      @proc.run input
    end

  end
end
