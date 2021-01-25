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

      def run input, params = {}
        kaf = KAF::Document.from_xml input

        @cache_keys = params[:cache_keys] ||= {}
        @cache_keys.merge! lang: kaf.language
        @map = kaf.map = CACHE[**@cache_keys].lexicons

        raise Opener::Core::UnsupportedLanguageError, kaf.language if @map.blank?

        kaf.terms.each do |t|
          lemma = t.lemma&.downcase
          text  = t.text.to_s.downcase
          pos   = if @ignore_pos then nil else t.pos end
          attrs = Hashie::Mash.new

          # text matching have priority as sometimes
          # the lemma provided by Stanza is a different word
          lexicon, polarity_pos = @map.by_polarity text, pos
          lexicon, polarity_pos = @map.by_polarity lemma, pos if lexicon.polarity == 'unknown'

          if l = @map.by_negator(text) || @map.by_negator(lemma)
            lexicon, polarity_pos = l, nil
            attrs.sentiment_modifier = 'shifter'
          elsif l = @map.by_intensifier(text) || @map.by_intensifier(lemma)
            lexicon, polarity_pos = l, nil
            attrs.sentiment_modifier = 'intensifier'
          elsif lexicon.polarity != 'unknown'
            attrs.polarity = lexicon.polarity
          end

          if attrs.size > 0
            attrs['lexicon-id'] = lexicon.id.to_s  if lexicon.id
            attrs.resource      = lexicon.resource if lexicon.resource
            t.setPolarity attrs, polarity_pos
          end
        end

        kaf.add_linguistic_processor DESC, "#{LAST_EDITED}_#{VERSION}", 'terms'

        kaf.to_xml
      end

    end
  end
end
