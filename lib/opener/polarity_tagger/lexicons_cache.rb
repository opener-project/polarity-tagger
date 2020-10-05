module Opener
  class PolarityTagger
    class LexiconsCache

      include MonitorMixin

      def initialize
        super #MonitorMixin

        @url   = ENV['POLARITY_LEXICON_URL']
        @path  = ENV['POLARITY_LEXICON_PATH']
        @cache = {}
      end

      def [] **params
        synchronize do
          existing = @cache[params]
          lexicons = load_lexicons cache: existing, **params

          @cache[params] = if lexicons.blank? then existing else
            Hashie::Mash.new(
              lexicons: lexicons,
              from:     Time.now,
            )
          end
        end
      end
      alias_method :get, :[]

      def load_lexicons lang:, **params
        lexicons = if @url then load_from_url lang: lang, **params else load_from_path lang: lang, **params end

        LexiconMap.new lang: lang, lexicons: lexicons
      end

      def load_from_url lang:, cache:, **params
        url  = "#{@url}&language_code=#{lang}&#{params.to_query}"
        url += "&if_updated_since=#{cache.from.iso8601}" if cache
        puts "#{lang}: loading lexicons from url #{url}"

        lexicons = JSON.parse HTTPClient.new.get(url).body
        lexicons = lexicons['data'].map{ |l| Hashie::Mash.new l }
        lexicons
      end

      def load_from_path lang:, **params
        @path  ||= 'core/general-lexicons'
        dir      = "#{@path}/#{lang.upcase}-lexicon"
        config   = Nokogiri::XML File.read "#{dir}/config.xml"
        lexicons = []

        config.css(:lexicon).each do |cl|
          filename = cl.at(:filename).text
          resource = cl.at(:resource).text
          xml      = Nokogiri::XML File.read "#{dir}/#{filename}"
          puts "#{lang}: loading lexicons from the file #{filename}"

          lexicons.concat(xml.css(:LexicalEntry).map do |le|
            Hashie::Mash.new(
              resource:   resource,
              identifier: le.attr(:id),
              type:       le.attr(:type),
              lemma:      le.at(:Lemma).attr(:writtenForm).downcase,
              pos:        le.attr(:partOfSpeech)&.downcase,
              aspect:     le.at(:Domain)&.attr(:aspect)&.downcase,
              polarity:   le.at(:Sentiment).attr(:polarity),
              strength:   le.at(:Sentiment).attr(:strength),
              confidence_level:   le.at(:Confidence)&.attr(:level),
              domain_conditional: le.at(:Domain)&.attr(:conditional) == 'yes',
            )
          end)
        end

        lexicons
      end

    end
  end
end
