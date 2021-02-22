module Opener
  class PolarityTagger
    class LexiconMap

      attr_reader :resource
      attr_reader :negators
      attr_reader :intensifiers
      attr_reader :with_polarity

      POS_ORDER     = 'ONRVGA'
      DEFAULT_POS   = 'O'
      POS_SHORT_MAP = {
        adj:         'G',
        adv:         'A',
        noun:        'N',
        propernoun:  'N',
        prep:        'P',
        verb:        'V',
        other:       DEFAULT_POS,
        nil =>       DEFAULT_POS,
        multi_word_expression: DEFAULT_POS,
      }

      def initialize lang:, lexicons:
        @lang          = lang
        @lexicons      = lexicons

        @negators      = {}
        @intensifiers  = {}
        @with_polarity = {}
        map lexicons
      end

      def blank?
        @lexicons.blank?
      end

      def by_negator lemma
        @negators[lemma]
      end

      def by_intensifier lemma
        @intensifiers[lemma]
      end

      def by_polarity lemma, identified_short_pos
        hash = Hashie::Mash.new multi: (@with_polarity[lemma] || [])

        if identified_short_pos and lexicon = @with_polarity[lemma+identified_short_pos]
          hash[:single] = lexicon
          return [hash, identified_short_pos]
        end

        POS_ORDER.chars.each do |short_pos|
          if lexicon = @with_polarity[lemma+short_pos]
            hash[:single] = lexicon
            return [hash, identified_short_pos]
          end
        end

        [hash, 'unknown']
      end

      protected

      def map lexicons
        return if blank?

        lexicons.each do |lexicon|
          next if lexicon.lemma.nil?

          sub_lexicons = [lexicon]
          sub_lexicons += lexicon.variants if lexicon.variants

          sub_lexicons.each do |variant|
            if variant.lemma.strip.include? ' '
              lemma = variant.lemma.strip.split(' ').first
              type = :multi
            else
              lemma = variant.lemma
              type = :single
            end

            if ['polarityShifter', 'intensifier'].include? lexicon.type
              var = @negators if lexicon.type == 'polarityShifter'
              var = @intensifiers if lexicon.type == 'intensifier'

              var[lemma] ||= Hashie::Mash.new multi: []
              if type == :multi
                var[lemma][:multi] << lexicon
              else
                var[lemma][:single] = lexicon
              end
            else
              map_one_polarity lemma, variant, lexicon if lexicon.polarity
            end
          end
        end

        puts "#{@lang}: loaded #{@negators.size} negators"
        puts "#{@lang}: loaded #{@intensifiers.size} intensifiers"
        puts "#{@lang}: loaded #{@with_polarity.size} elements with polarity"
      end

      def map_one_polarity lemma, hash, lexicon
        poses = if hash.poses.present? then hash.poses else [hash.pos] end
        poses.each do |pos|
          short_pos = POS_SHORT_MAP[pos&.to_sym] || DEFAULT_POS
          @with_polarity[lemma] ||= []
          if hash.lemma.strip.include? ' '
            @with_polarity[lemma] << lexicon
          else
            @with_polarity[lemma+short_pos] = lexicon
          end
        end
      end

    end
  end
end
