require 'opener/webservice'

module Opener
  class PolarityTagger
    ##
    # Polarity tagger server powered by Sinatra.
    #
    class Server < Webservice::Server
      set :views, File.expand_path('../views', __FILE__)

      self.text_processor  = PolarityTagger
      self.accepted_params = [:input]
    end # Server
  end # PolarityTagger
end # Opener
