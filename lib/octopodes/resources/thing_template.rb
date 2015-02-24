require 'octopodes/resources/thing'

module Octopodes
  module Resources
    # Thing Template resource
    class ThingTemplate < Thing
      include Octopodes::Resources::ReadWriteProtected

      private

      def title
        'Edit ' + super.singularize
      end

      # Set the collection uri to the model resource, so that the form `action`
      #   will POST to that URL.
      def collection_uri
        super + uuid + '/'
      end

      def include_template?
        true
      end

      def include_items?
        false
      end

      def links
        @links = []

        if class_title == 'Things'
          @links << { href: base_uri + 'schema/things/',
                      rel: 'things', prompt: 'All Records' }
        else
          @links << { href: collection_uri,
                      rel: 'template', prompt: 'View' }
        end

        @links
      end

      def total
        1
      end
    end
  end
end
