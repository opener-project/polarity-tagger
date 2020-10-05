require 'open3'
require 'opener/core'
require 'nokogiri'
require 'hashie'
require 'active_support/all'

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

    def clear_cache params = {}
      @proc.clear_cache(**params)
    end

    def run input, params = {}
      @proc.run input, params
    end

  end
end
