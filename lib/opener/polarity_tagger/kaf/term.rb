module Opener
  module KAF
    class Term

      attr_reader :document
      attr_reader :node

      def initialize document, node
        @document = document
        @node     = node
      end

      def id
        @id ||= @node.attr :tid
      end

      def lemma
        @node.attr :lemma
      end

      def pos
        @node.attr :pos
      end

      def setPolarity attrs, polarity_pos
        #In case there is no pos info, we use the polarityPos
        @node[:pos] = polarity_pos if !pos and polarity_pos

        sentiment = @node.add_child('<sentiment/>')
        sentiment.attr attrs
      end

    end
  end
end
