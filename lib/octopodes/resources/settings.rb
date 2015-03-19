require 'octopodes/resources/collection'
require 'octopodes/repositories/user'

module Octopodes
  module Resources
    # User Settings Resource
    class Settings < User
      include Octopodes::Resources::ReadWriteProtected

      def allowed_methods
        ['GET', 'POST']
      end

      def forbidden?
        forbidden = !client_is_user?
        if forbidden
          @response.body = Views::Pages.new('blank', 'Forbidden', menu).render
        end
        forbidden
      end

      def post_is_create?
        true
      end

      def create_path
        collection_uri + create_id
      end

      def from_cj
        template = Presenters::CollectionTemplateDecoder.new(request.body.to_s)
        process_data(:update, repository, create_id, template, :to_cj)
      end

      def from_urlencoded
        form = Presenters::WwwFormDecoder.new(request.body.to_s)
        process_data(:update, repository, create_id, form, :to_html)
      end

      private

      def create_id
        @create_id ||= repository.token
      end

      # Set the collection uri to this resource, so that the form `action`
      #   will POST here.
      def collection_uri
        super + username + '/' + 'settings/'
      end

      def include_items?
        false
      end

      def include_template?
        true
      end

      def links
        [{ href: collection_uri, rel: 'up', prompt: 'Cancel' }]
      end
    end
  end
end
