require_relative 'lexicons_cache'
require_relative 'lexicon_map'
require_relative '../kaf/document'

module Opener
  class PolarityTagger
    class Internal

      DESC        = 'VUA polarity tagger multilanguage'
      LAST_EDITED = '21may2014'
      VERSION     = '1.2'
      N_WORDS     = 5

      CACHE       = LexiconsCache.new

      def initialize ignore_pos: false, **params
        @ignore_pos = ignore_pos
      end

      def run input, params = {}
        kaf         = KAF::Document.from_xml input

        @cache_keys = params[:cache_keys] ||= {}
        @cache_keys.merge! lang: kaf.language
        @cache_keys[:contract_ids] = nil unless @cache_keys[:contract_ids]
        @cache_keys = @cache_keys.except :property_type
        @map = kaf.map = CACHE[**@cache_keys].lexicons

        raise Opener::Core::UnsupportedLanguageError, kaf.language if @map.blank?

        next_index = 0
        kaf.terms.each_with_index do |t, index|
          # skip terms when a multi_word_expression is found
          next if next_index > index
          lemma = t.lemma&.downcase
          text  = t.text.to_s.downcase
          pos   = if @ignore_pos then nil else t.pos end
          attrs = Hashie::Mash.new


          polarity_pos = nil

          if opts = @map.by_negator(text) || @map.by_negator(lemma)
            lexicon, next_index = get_lexicon(opts, kaf, index)
            attrs.sentiment_modifier = 'shifter' if lexicon
          elsif opts = @map.by_intensifier(text) || @map.by_intensifier(lemma)
            lexicon, next_index = get_lexicon(opts, kaf, index)
            attrs.sentiment_modifier = 'intensifier' if lexicon
          end

          unless lexicon
            # text matching have priority as sometimes
            # the lemma provided by Stanza is a different word
            [text, lemma].each do |word|
              opts, polarity_pos = @map.by_polarity word, pos

              if opts[:multi].size > 0 or opts[:single]
                lexicon, next_index = get_lexicon opts, kaf, index
                if lexicon
                  attrs.polarity = lexicon.polarity
                  break
                end
              end
            end
          end

          if attrs.size > 0
            attrs['lexicon-id'] = lexicon.id.to_s  if lexicon&.id
            attrs.resource      = lexicon.resource if lexicon&.resource
            t.setPolarity attrs, polarity_pos
            i = index
            while i < next_index do
              term = kaf.terms[i]
              term.setPolarity attrs, polarity_pos
              i += 1
            end
          end
        end

        kaf.add_linguistic_processor DESC, "#{LAST_EDITED}_#{VERSION}", 'terms'

        kaf.to_xml
      end

      def get_lexicon opts, kaf, index
        if lexicon = identify_lexicon(kaf.terms[index, N_WORDS], opts.multi)
          index = index + lexicon.lemma.strip.split(' ').size
        else
          lexicon = opts.single
        end

        [lexicon, index]
      end

      def identify_lexicon terms, lexicons
        return unless lexicons.size > 0

        lemma = terms.map{|t| t.lemma&.downcase }.join(' ')
        text  = terms.map{|t| t.text&.downcase }.join(' ')

        lexicons.each do |lexicon|
          return lexicon if lemma =~ /^#{Regexp.escape(lexicon.lemma)}($|\s)+/
          return lexicon if text =~ /^#{Regexp.escape(lexicon.lemma)}($|\s)+/
        end
        nil
      end

    end
  end
end
