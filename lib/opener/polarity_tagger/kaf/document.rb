require_relative 'term'

module Opener
  module KAF
    class Document

      attr_reader :document
      attr_reader :lexicons

      attr_accessor :map

      def initialize xml
        @document = xml
      end

      def self.from_xml xml
        new Nokogiri::XML xml
      end

      def language
        @language ||= @document.at_xpath('KAF').attr 'xml:lang'
      end

      def terms
        @terms ||= collection 'KAF/terms/term', Term
      end

      def add_linguistic_processor name, version, layer, timestamp: false
        header  = @document.at('kafHeader') || @document.root.add_child('<kafHeader/>').first
        procs   = header.css('linguisticProcessors').find{ |l| l.attr(:layer) == layer }
        procs ||= header.add_child("<linguisticProcessors layer='#{layer}'/>").first
        lp      = procs.add_child('<lp/>')
        lp.attr(
          timestamp: if timestamp then Time.now.iso8601 else '*' end,
          version:   version,
          name:      name,
        )
        lp
      end

      def to_xml
        @document.to_xml indent: 2
      end

      protected

      def collection query, wrapper
        @document.xpath(query).map{ |node| wrapper.new self, node }
      end

    end
  end
end
