require 'octopodes/resources/users'
require 'octopodes/repositories/user'

module Octopodes
  module Resources
    # User Resource
    class User < Users
      def resource_exists?
        dataset.count > 0
      end

      private

      def title
        username
      end

      def dataset
        @dataset ||= repository.find(username)
      end

      def username
        @request.path_info[:username]
      end

      def links
        links = super
        if include_settings_link?
          links << { href: collection_uri + "#{username}/settings/",
                     rel: 'template', prompt: 'Settings' }
        end
        links
      end

      def include_settings_link?
        client_is_user?
      end

      def client_is_user?
        !@user.nil? && @user.username == username
      end
    end
  end
end
