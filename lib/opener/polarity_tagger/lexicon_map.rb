module Opener
  class PolarityTagger
    class LexiconMap

      attr_reader :resource
      attr_reader :negators
      attr_reader :intensifiers
      attr_reader :with_polarity

      POS_ORDER = 'NRVGA'
      UNKNOWN   = Hashie::Mash.new polarity: 'unknown'

      def initialize lang:, lexicons:
        @lang          = lang
        @lexicons      = lexicons

        @negators      = {}
        @intensifiers  = {}
        @with_polarity = {}
        map lexicons
      end

      POS_SHORT_MAP = {
        adj:         'G',
        adv:         'A',
        noun:        'N',
        propernoun:  'N',
        other:       'O',
        prep:        'P',
        verb:        'V',
        nil =>       'O',
        multi_word_expression: 'O',
      }

      def by_negator lemma
        @negators[lemma]
      end

      def by_intensifier lemma
        @intensifiers[lemma]
      end

      def by_polarity lemma, short_pos
        return [@with_polarity[lemma+short_pos] || UNKNOWN, short_pos] if short_pos

        POS_ORDER.chars.each do |short_pos|
          if l = @with_polarity[lemma+short_pos]
            puts "Found polarify #{l.polarity} for #{lemma} with PoS #{short_pos}"
            return [l, short_pos]
          end
        end

        [UNKNOWN, 'unknown']
      end

      protected

      def map lexicons
        lexicons.each do |l|
          next if l.lemma.nil?

          case l.type
          when 'polarityShifter' then @negators[l.lemma]     = l
          when 'intensifier'     then @intensifiers[l.lemma] = l
          else
            if l.polarity
              short_pos = POS_SHORT_MAP[l.pos&.to_sym]
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
