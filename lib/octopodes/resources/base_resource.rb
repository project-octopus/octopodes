require 'webmachine'
require 'configatron'
require 'openssl'

require 'octopodes/resources/access'
require 'octopodes/views'

module Octopodes
  module Resources
    # Base Resource
    class BaseResource < Webmachine::Resource
      include Webmachine::Resource::Authentication
      include Resources::ReadOnly

      # Returning anything other than true will result in a '401 Unauthorized'
      # response. If a String is returned, it will be used as the value in the
      # WWW-Authenticate header.
      def is_authorized?(authorization_header)
        if must_authorize? || requesting_auth?(authorization_header)
          check_authorization(authorization_header)
        else
          true
        end
      end

      private

      # Check if the user is requesting authorization, via http header
      # or cookies.
      def requesting_auth?(authorization_header)
        authorization_header || !authorization_cookie.blank?
      end

      # Check if the user is authorized. If not, set the response body
      # manually to an error page. (Otherwise the client will get a blank
      # response body.)
      def check_authorization(authorization_header)
        authorized = check_credentials(authorization_header)

        @response.body = unauthorized_response unless authorized == true

        authorized
      end

      # If an authorization header is supplied, check basic auth. If a cookie
      # is supplied, check it.
      def check_credentials(authorization_header)
        if authorization_header
          check_basic_auth(authorization_header)
        elsif authorization_cookie
          check_cookie_auth(authorization_cookie)
        end
      end

      # Returns true if the username and password are correct, otherwise a
      # String value for the WWW-Authenticate header.
      def check_basic_auth(authorization_header)
        basic_auth(authorization_header, 'Project Octopus') do |user, pass|
          @user = Repositories::User.authenticate(user, pass)
          !@user.nil?
        end
      end

      # Checks the user cookie for a correctly signed username. The cookie
      # should look like: "_Octopodes_identity=username--SIGNATURE". Returns
      # true or false.
      def check_cookie_auth(auth_cookie)
        if !auth_cookie.blank?
          username, hmac = auth_cookie.to_s.split('--')
          digest = OpenSSL::Digest::SHA1.new
          secret = configatron.secret_token
          expected = OpenSSL::HMAC.hexdigest(digest, secret, username)

          @user = Repositories::User.find(username).first if hmac == expected

          !@user.nil?
        else
          false
        end
      end

      def auth_cookie_name
        '_Octopodes_identity'
      end

      def authorization_cookie
        request.cookies[auth_cookie_name]
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
          menu_items << { href: "#{base}sessions", prompt: 'Login' }
        else
          menu_items << { href: "#{base}users/#{@user.username}",
                          prompt: @user.username }
          menu_items << { href: "#{base}sessions/end", prompt: 'Logout' }
        end

        menu_items
      end
    end
  end
end
