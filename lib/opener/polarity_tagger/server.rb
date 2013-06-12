require 'sinatra/base'
require 'httpclient'

module Opener
  class PolarityTagger
    ##
    # Polarity tagger server powered by Sinatra.
    #
    class Server < Sinatra::Base
      configure do
        enable :logging
      end

      configure :development do
        set :raise_errors, true
        set :dump_errors, true
      end

      ##
      # Presents a simple form that can be use for tagging the polarity of a
      # KAF document.
      #
      get '/' do
        erb :index
      end

      ##
      # Tags the polarity of a KAF document.
      #
      # @param [Hash] params The POST parameters.
      #
      # @option params [String] :text The KAF to tag.
      # @option params [Array<String>] :callbacks A collection of callback URLs
      #  that act as a chain. The results are posted to the first URL which is
      #  then shifted of the list.
      # @option params [String] :error_callback Callback URL to send errors to
      #  when using the asynchronous setup.
      #
      post '/' do
        if !params[:text] or params[:text].strip.empty?
          logger.error('Failed to process the request: no KAF specified')

          halt(400, 'No KAF specified')
        end

        if params[:callbacks] and !params[:callbacks].strip.empty?
          process_async
        else
          process_sync
        end
      end

      ##
      # Processes the request synchronously.
      #
      def process_sync
        output = tag_polarity(params[:text])

        content_type(:xml)

        body(output)
      rescue => error
        logger.error("Failed to tag the text: #{error.inspect}")

        halt(500, error.message)
      end

      ##
      # Processes the request asynchronously.
      #
      def process_async
        callbacks = params[:callbacks]
        callbacks = [callbacks] unless callbacks.is_a?(Array)

        Thread.new do
          tag_polarity_async(params[:text], callbacks, params[:error_callback])
        end

        status(202)
      end

      ##
      # Tags the polarity of a KAF document.
      #
      # @param [String] text The KAF to tokenize.
      # @return [String]
      # @raise RunetimeError Raised when the tagging process failed.
      #
      def tag_polarity(text)
        tagger                = PolarityTagger.new
        output, error, status = tagger.run(text)

        raise(error) unless status.success?

        return output
      end

      ##
      # Tags the polarity of a KAF document and submits the results to a
      # callback URL.
      #
      # @param [String] text
      # @param [Array] callbacks
      # @param [String] error_callback
      #
      def tag_polarity_async(text, callbacks, error_callback = nil)
        begin
          output = tag_polarity(text)
        rescue => error
          logger.error("Failed to tag the polarity: #{error.inspect}")

          submit_error(error_callback, error.message) if error_callback
        end

        url = callbacks.shift

        logger.info("Submitting results to #{url}")

        begin
          process_callback(url, output, callbacks)
        rescue => error
          logger.error("Failed to submit the results: #{error.inspect}")

          submit_error(error_callback, error.message) if error_callback
        end
      end

      ##
      # @param [String] url
      # @param [String] text
      # @param [Array] callbacks
      #
      def process_callback(url, text, callbacks)
        HTTPClient.post(
          url,
          :body => {:text => text, :callbacks => callbacks, :kaf => true}
        )
      end

      ##
      # @param [String] url
      # @param [String] message
      #
      def submit_error(url, message)
        HTTPClient.post(url, :body => {:error => message})
      end
    end # Server
  end # PolarityTagger
end # Opener
