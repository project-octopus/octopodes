require 'octopodes/resources/collection'
require 'octopodes/repositories/user'

module Octopodes
  module Resources
    # User Setting Resource
    class Setting < Collection
      def allowed_methods
        ['GET']
      end

      def resource_exists?
        token_valid? && Repositories::User.identify(token)
      end

      private

      def title
        'Please login again'
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
