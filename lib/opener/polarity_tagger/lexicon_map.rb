module Opener
  class PolarityTagger
    class LexiconMap

      attr_reader :resource
      attr_reader :negators
      attr_reader :intensifiers
      attr_reader :with_polarity

      UNKNOWN = Hashie::Mash.new polarity: 'unknown'

      POS_ORDER     = 'NRVGAO'
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

      def by_polarity lemma, short_pos
        l = @with_polarity[lemma+short_pos] if short_pos
        return [l, short_pos] if l

        POS_ORDER.chars.each do |short_pos|
          l = @with_polarity[lemma+short_pos]
          return [l, short_pos] if l
        end

        [UNKNOWN, 'unknown']
      end

      protected

      def map lexicons
        return if blank?

        lexicons.each do |l|
          next if l.lemma.nil?

          case l.type
          when 'polarityShifter' then @negators[l.lemma]     = l
          when 'intensifier'     then @intensifiers[l.lemma] = l
          else
            if l.polarity
              short_pos = POS_SHORT_MAP[l.pos&.to_sym] || DEFAULT_POS
              @with_polarity[l.lemma+short_pos] = l
            end
          end
        end

        puts "#{@lang}: loaded #{@negators.size} negators"
        puts "#{@lang}: loaded #{@intensifiers.size} intensifiers"
        puts "#{@lang}: loaded #{@with_polarity.size} elements with polarity"
      end

    end
  end
end
