require 'octopodes/resources/collection'
require 'octopodes/repositories/user'

module Octopodes
  module Resources
    # User Setting Resource
    class Setting < Settings
      def allowed_methods
        ['GET']
      end

      def resource_exists?
        token_valid? && Repositories::User.identify(token)
      end

      private

      def title
        'Settings updated'
      end

      def include_items?
        false
      end

      def include_template?
        false
      end

      def links
        []
      end

      def token
        request.path_info[:token]
      end

      def token_valid?
        (token =~ /^([a-f\d]{8}(-[a-f\d]{4}){3}-[a-f\d]{12}?)$/i) == 0
      end
    end
  end
end
