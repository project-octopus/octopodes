require 'configatron'
require 'collection-json'

require 'octopodes/resources/base_resource'

module Octopodes
  module Resources
    # Collection Resource
    class Collection < BaseResource
      def content_types_provided
        [['text/html', :to_html],
         ['application/vnd.collection+json', :to_cj]]
      end

      def content_types_accepted
        [['application/x-www-form-urlencoded', :from_urlencoded],
         ['application/vnd.collection+json', :from_cj]]
      end

      def base_uri
        @request.base_uri.to_s
      end

      def to_html
        Views::Collection.new(collection, title, menu, body).render
      end

      def to_cj
        collection.to_json
      end

      def trace?
        configatron.webmachine.trace
      end

      private

      def title
        'Reviewing the Use of Creative Works, One URL at a Time'
      end

      def body; end

      def collection
        CollectionJSON.generate_for(base_uri) do |builder|
          builder.set_version('1.0')
        end
      end

      def startkey
        @request.query['startkey']
      end

      def prevkey
        @request.query['prevkey']
      end

      def limit
        min, max, default = 1, 500, 10
        req = @request.query['limit']
        (req =~ /^\d+$/) ? [min, [req.to_i, max].min].max : default
      end

      def links
        []
      end

      def form_data
        form = URI.decode_www_form(request.body.to_s)
        form.each_with_object({}) do |value, hash|
          hash[value.first] = value.last
        end
      end
    end
  end
end
