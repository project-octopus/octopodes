require 'octopodes/resources/collection'
require 'octopodes/presenters/collection'
require 'octopodes/repositories/user'
require 'octopodes/repositories/web_page'

module Octopodes
  module Resources
    # Home Resource
    class Home < Collection
      def to_html
        Views::Pages.new('home', title, menu).render
      end

      def collection
        options = { base_uri: base_uri, collection_uri: base_uri,
                    links: links }
        Presenters::Collection.new([], options)
      end

      def links
        [{ href: base_uri + 'schema/things/',
           rel: 'things', prompt: 'All Records' }]
      end
    end
  end
end
