require_relative 'lexicons_cache'
require_relative 'lexicon_map'
require_relative 'kaf/document'

module Opener
  class PolarityTagger
    class Internal

      DESC        = 'VUA polarity tagger multilanguage'
      LAST_EDITED = '21may2014'
      VERSION     = '1.2'

      def initialize ignore_pos: false, **params
        @cache = LexiconsCache.new

        @ignore_pos = ignore_pos
      end

      def run input
        @kaf = KAF::Document.from_xml input
        @map = @kaf.map = @cache[@kaf.language]

        negators = 0
        @kaf.terms.each do |t|
          lemma = t.lemma&.downcase
          pos   = if @ignore_pos then nil else t.pos end
          attrs = Hashie::Mash.new

          lexicon, polarity_pos = @map.by_polarity lemma, pos

          if lexicon.polarity != 'unknown'
            attrs.polarity = lexicon.polarity
          end
          if l = @map.by_negator(lemma)
            negators += 1
            lexicon, polarity = l, nil
            attrs.sentiment_modifier = 'shifter'
          end
          if l = @map.by_intensifier(lemma)
            lexicon, polarity = l, nil
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
