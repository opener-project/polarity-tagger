module Opener
  class PolarityTagger
    class LexiconMap

      attr_reader :resource
      attr_reader :negators
      attr_reader :intensifiers
      attr_reader :with_polarity

      POS_ORDER = 'NRVGA'
      UNKNOWN   = Hashie::Mash.new polarity: 'unknown'

      def initialize lang:, lexicons:, resource: nil
        @lang          = lang
        @lexicons      = lexicons
        @resource      = resource

        @negators      = []
        @intensifiers  = []
        @with_polarity = {}
        map lexicons
      end

      POS_KAF_MAP = {
        adj:   'G',
        adv:   'A',
        noun:  'N',
        other: 'O',
        prep:  'P',
        verb:  'V',
        nil => 'O',
        multi_word_expression: 'O',
      }

      def by_negator lemma
        @negators.find{ |l| l.lemma == lemma }
      end

      def by_intensifier lemma
        @intensifiers.find{ |l| l.lemma == lemma }
      end

      def by_polarity lemma, pos
        l = @with_polarity[[lemma,pos]]
        return [l || UNKNOWN, pos] if pos

        POS_ORDER.chars.each do |newpos|
          if l = @with_polarity[[lemma,newpos]]
            puts "Found polarify #{l.polarity} for #{lemma} with PoS #{newpos}"
            return [l, newpos]
          end
        end

        [UNKNOWN, 'unknown']
      end

      def map lexicons
        lexicons.each do |l|
          next if l.lemma.nil?

          case l.type
          when 'polarityShifter' then @negators     << l
          when 'intensifier'     then @intensifiers << l
          else
            if l.polarity
              short_pos = POS_KAF_MAP[l.pos&.downcase&.to_sym]
              @with_polarity[[l.lemma, short_pos]] = l
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
