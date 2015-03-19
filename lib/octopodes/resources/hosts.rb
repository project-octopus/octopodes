require 'octopodes/resources/collection'
require 'octopodes/presenters/collection'
require 'octopodes/repositories/host'
require 'octopodes/repositories/thing'

module Octopodes
  module Resources
    # Hosts resource
    class Hosts < Collection
      def allowed_methods
        ['GET']
      end

      def dataset
        @dataset ||= Repositories::Host.popular
      end

      private

      def title
        'Web Hosts'
      end

      def collection
        options = { base_uri: base_uri, collection_uri: collection_uri,
                    links: links }
        Presenters::Collection.new(dataset, options).to_cj
      end

      def collection_uri
        base_uri + 'hosts/'
      end

      def links
        [{ href: collection_uri, rel: 'index', prompt: 'All Hosts' }]
      end
    end

    # Host resource
    class Host < Hosts
      private

      def collection_uri
        super + hostname + '/'
      end

      def collection
        options = { base_uri: base_uri, collection_uri: collection_uri,
                    links: links, limit: limit, startkey: startkey,
                    prevkey: prevkey, total: total }
        Presenters::Collection.new(dataset, options).to_cj
      end

      def dataset
        options = { limit: limit, stattkey: startkey }
        @dataset ||= Repositories::Thing.find_by_hostname(hostname, options)
      end

      def total
        @total ||= Repositories::Thing.count_by_hostname(hostname)
      end

      def title
        'Records for ' + hostname
      end

      def hostname
        @request.path_info[:hostname]
      end

      def links
        [{ href: base_uri + 'hosts/', rel: 'index', prompt: 'All Hosts' }]
      end
    end
  end
end
