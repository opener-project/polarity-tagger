require_relative 'lexicons_cache'
require_relative 'lexicon_map'
require_relative '../kaf/document'

module Opener
  class PolarityTagger
    class Internal

      DESC        = 'VUA polarity tagger multilanguage'
      LAST_EDITED = '21may2014'
      VERSION     = '1.2'

      CACHE = LexiconsCache.new

      def initialize ignore_pos: false, **params
        @ignore_pos = ignore_pos
      end

      def clear_cache lang: nil, environment:
      end

      def run input, params = {}
        @kaf = KAF::Document.from_xml input

        @cache_keys = params[:cache_keys] ||= {}
        @cache_keys.merge! lang: @kaf.language
        @map = @kaf.map = CACHE[**@cache_keys].lexicons

        raise Opener::Core::UnsupportedLanguageError, @kaf.language if @map.blank?

        @kaf.terms.each do |t|
          lemma = t.lemma&.downcase
          text  = t.text.to_s.downcase
          pos   = if @ignore_pos then nil else t.pos end
          attrs = Hashie::Mash.new

          lexicon, polarity_pos = @map.by_polarity lemma, pos
          lexicon, polarity_pos = @map.by_polarity text, pos if lexicon.polarity == 'unknown'

          if lexicon.polarity != 'unknown'
            attrs.polarity = lexicon.polarity
          end
          if l = @map.by_negator(lemma) || @map.by_negator(text)
            lexicon, polarity_pos = l, nil
            attrs.sentiment_modifier = 'shifter'
          end
          if l = @map.by_intensifier(lemma) || @map.by_intensifier(text)
            lexicon, polarity_pos = l, nil
            attrs.sentiment_modifier = 'intensifier'
          end

          if attrs.size > 0
            attrs.resource = lexicon.resource if lexicon.resource
            t.setPolarity attrs, polarity_pos
          end
        end

        @kaf.add_linguistic_processor DESC, "#{LAST_EDITED}_#{VERSION}", 'terms'

        @kaf.to_xml
      end

    end
  end
end
