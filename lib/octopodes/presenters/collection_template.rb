require 'json'
require 'collection-json'

module Octopodes
  module Presenters
    # Accepts raw Collection+JSON template and outputs it as an array of hashes
    class CollectionTemplateDecoder
      attr_reader :error

      def initialize(json = '')
        cj_raw = '{"collection":' + json.to_s + '}'
        @cj = CollectionJSON.parse(cj_raw)
      rescue JSON::ParserError
        message = 'Malformed Collection+JSON'
        @error = { 'title' => 'Bad Input', 'message' => message }
      end

      def valid?
        @error.nil? && !@cj.template.nil? && !@cj.template.data.empty?
      end

      def to_hash
        if valid?
          @cj.template.data.each_with_object({}) do |data, hash|
            nv = data.to_hash
            hash[nv[:name]] = nv[:value].strip if nv[:name] && nv[:value]
          end
        else
          {}
        end
      end
    end
  end
end
