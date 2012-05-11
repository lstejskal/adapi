
# This monkeypatch adds option to prettify Savon SOAP log
#
# Not necessary, but very convenient feature - unless you're fond of deciphering
# endless SOAP request/response one-liners.
#
# Can be safely removed. Should be only temporary, as the idea is taken straight
# out of Savon pull requests and should be included in its future version.

module Savon
  module Config

   # Logs a given +message+. Optionally filtered if +xml+ is truthy.
    def log(message, xml = false)
      return unless log?

      # ORIG
      # message = filter_xml(message) if xml && !log_filter.empty?

      # NEW: always run filter_xml method 
      message = filter_xml(message) # if xml && !log_filter.empty?

      logger.send log_level, message
    end

    # Filters the given +xml+ based on log filter.
    def filter_xml(xml)
      doc = Nokogiri::XML(xml)
      return xml unless doc.errors.empty?

      log_filter.each do |filter|
        doc.xpath("//*[local-name()='#{filter}']").map { |node| node.content = "***FILTERED***" }
      end

      # ORIG
      # doc.root.to_s

      # NEW: return formatted SOAP
      doc.to_xml(:indent => 2)
    end

  end
end
