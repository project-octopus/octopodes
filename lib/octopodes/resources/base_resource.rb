require 'webmachine'

require 'octopodes/resources/access'
require 'octopodes/views'

module Octopodes
  module Resources
    # Base Resource
    class BaseResource < Webmachine::Resource
      include Webmachine::Resource::Authentication
      include Resources::ReadOnly

      def is_authorized?(authorization_header)
        authorization = user_auth(authorization_header)
        if must_authorize? && authorization != true
          @response.body = unauthorized_response
          authorization
        else
          true
        end
      end

      private

      def user_auth(authorization_header)
        basic_auth(authorization_header, 'Project Octopus') do |user, pass|
          @user = Repositories::User.authenticate(user, pass)
          !@user.nil?
        end
      end

      def unauthorized_response
        Views::Pages.new('blank', 'Please sign in', menu).render
      end

      def menu
        base = @request.base_uri.to_s
        menu_items = [{ href: "#{base}schema/things", prompt: 'Works' }]
        menu_items << { href: "#{base}hosts/", prompt: 'Hosts' }

        if @user.nil?
          menu_items << { href: "#{base}signups", prompt: 'Sign up' }
          menu_items << { href: "#{base}login", prompt: 'Login' }
        else
          menu_items << { href: "#{base}users/#{@user.username}", prompt: @user.username }
        end

        menu_items
      end
    end
  end
end
