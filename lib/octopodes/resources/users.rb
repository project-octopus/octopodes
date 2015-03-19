require 'octopodes/resources/collection'
require 'octopodes/repositories/user'

module Octopodes
  module Resources
    # Users Resource
    class Users < Collection
      def allowed_methods
        ['GET']
      end

      def collection_uri
        @collection_uri ||= base_uri + 'users/'
      end

      private

      def title
        'Users'
      end

      def dataset
        @dataset ||= repository.list(limit: limit, startkey: startkey)
      end

      def collection
        options = { base_uri: base_uri, collection_uri: collection_uri,
                    include_items: include_items?,
                    include_template: include_template?,
                    links: links, limit: limit, total: total,
                    startkey: startkey, prevkey: prevkey }
        Presenters::Collection.new(dataset, options).to_cj
      end

      def include_items?
        true
      end

      def include_template?
        false
      end

      def total
        @total ||= repository.count
      end

      def repository
        Repositories::User
      end

      def links
        [{ href: collection_uri, rel: 'index', prompt: 'All Users' }]
      end
    end
  end
end
