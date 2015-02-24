require 'octopodes/resources/collection'

module Octopodes
  module Resources
    # Login Resource
    class Login < Collection
      include Octopodes::Resources::ReadWriteProtected

      def content_types_provided
        [['text/html', :to_html]]
      end

      private

      def title
        'Thank you for logging in'
      end

      def unauthorized_response
        Views::Collection.new(collection, 'Please try again or sign up for an account', menu).render
      end
    end
  end
end
