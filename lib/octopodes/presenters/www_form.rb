module Octopodes
  module Presenters
    # Accepts raw www_form and transforms it into an array of hashes
    class WwwFormDecoder
      attr_reader :error

      def initialize(url_encoded_form = '')
        if url_encoded_form.nil?
          @form = []
        else
          @form = URI.decode_www_form(url_encoded_form.to_s)
        end
      rescue ArgumentError
        @error = { 'title' => 'Bad Input', 'message' => 'Malformed WWW Form' }
      end

      def valid?
        @error.nil?
      end

      def to_hash
        @form.each_with_object({}) do |element, hash|
          key = element.first
          value = element.last.strip
          if key.end_with?('[]')
            bare_key = key[0..-3]
            if hash.key?(bare_key)
              hash[bare_key] = hash[bare_key].push(value)
            else
              hash[bare_key] = [value]
            end
          else
            hash[key] = value
          end
        end
      end
    end
  end
end
