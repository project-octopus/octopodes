require 'octopodes/resources/collection'
require 'octopodes/presenters/collection'
require 'octopodes/repositories/thing'

module Octopodes
  module Resources
    # Search resource
    class Search < Collection
      def allowed_methods
        ['GET']
      end

      private

      def title
        'Search Project Octopus'
      end

      def collection_uri
        base_uri + 'search/'
      end

      def collection
        options = { base_uri: base_uri, collection_uri: collection_uri,
                    links: links, error: error, limit: limit, total: total,
                    queries: queries,
                    startkey: startkey, prevkey: prevkey }
        Presenters::Collection.new(dataset, options).to_cj
      end

      def dataset
        options = { limit: limit, startkey: startkey }
        @dataset ||= Repositories::Thing.search(search_text, options)
      end

      def total
        @total ||= Repositories::Thing.search_count(search_text)
      end

      def error
        { 'title' => 'No results found' } if !search_text.nil? && total == 0
      end

      def links
        @links = []

        @links << { href: base_uri + 'schema/things/',
                    rel: 'things', prompt: 'All Records' }

        @links << { href: base_uri + 'schema/creative-works/',
                    rel: 'creative-works', prompt: 'Creative Works' }
        @links << { href: base_uri + 'schema/web-pages/',
                    rel: 'web-pages', prompt: 'Web Pages' }

        @links << { href: base_uri + 'search/',
                    rel: 'queries', prompt: 'Search' }

        @links
      end

      def queries
        @queries = []

        @queries << { href: base_uri + 'search/', rel: 'search',
                      prompt: 'Search',
                      data: [
                        ['text', value: search_text, prompt: 'Title or URL']
                      ]
                    }

        @queries
      end

      def search_text
        @request.query['text'].strip if @request.query['text']
      end
    end
  end
end
