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

      def [] lang
        synchronize do
          @cache[lang] ||= load_lexicons lang
        end
      end
      alias_method :get, :[]

      def load_lexicons lang
        lexicons = if @url then load_from_url lang else load_from_path lang end

        LexiconMap.new lang: lang, lexicons: lexicons
      end

      def load_from_url lang
        url      = "#{@url}&language_code=#{lang}"
        puts "#{lang}: loading lexicons from url #{url}"
        lexicons = JSON.parse HTTPClient.new.get(url).body
        lexicons = lexicons['data'].map{ |l| Hashie::Mash.new l }
        lexicons
      end

      def load_from_path lang
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
