require 'octopodes/presenters/atom'
require 'octopodes/resources/thing'
require 'octopodes/repositories/thing'

module Octopodes
  module Resources
    module Feed
      # Feed resource
      class Feed < Webmachine::Resource
        def allowed_methods
          ['GET']
        end

        def content_types_provided
          [['application/atom+xml', :to_atom]]
        end

        def base_uri
          @request.base_uri.to_s
        end

        def collection_uri
          base_uri + 'u/'
        end

        def to_atom
          options = { base_uri: base_uri, collection_uri: collection_uri }
          Presenters::Atom.new(dataset, options).to_s
        end

        private

        def dataset
          @dataset ||= Repositories::Thing.recent(limit: limit)
        end

        def limit
          20
        end
      end

      # Feed Item resource
      class Item < Thing
        def allowed_methods
          ['GET']
        end

        def resource_exists?
          false
        end

        def previously_existed?
          dataset.count > 0
        end

        def moved_temporarily?
          base_uri + dataset.first.href
        end

        def moved_permanently?
          false
        end

        private

        def dataset
          @dataset ||= Repositories::Thing.find(uuid)
        end
      end
    end
  end
end
