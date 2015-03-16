require 'octopodes/resources/collection'
require 'octopodes/repositories/user'

module Octopodes
  module Resources
    # Sessions Resource
    class Sessions < Signups
      def is_authorized?(_authorization_header)
        true
      end

      def from_cj
        template = Presenters::CollectionTemplateDecoder.new(request.body.to_s)
        process_data(:authenticate_data, create_id, template, :to_cj)
      end

      def from_urlencoded
        form = Presenters::WwwFormDecoder.new(request.body.to_s)
        process_data(:authenticate_data, create_id, form, :to_html)
      end

      def create_path
        collection_uri + 'new/'
      end

      private

      def collection_uri
        base_uri + 'sessions/'
      end

      def title
        'Sign in to Project Octopus'
      end

      # Sets a signed cookie for the username. The cookie should look
      # like: "_Octopodes_identity=username--SIGNATURE".
      def write_cookie_auth(username)
        digest = OpenSSL::Digest::SHA1.new
        secret = configatron.secret_token
        hmac = OpenSSL::HMAC.hexdigest(digest, secret, username)
        cookie = "#{username}--#{hmac}"

        attributes = { path: '/', httponly: true }
        response.set_cookie(auth_cookie_name, cookie, attributes)
      end

      def process_data(action, _uuid, from_data, content_handler)
        if from_data.valid?
          model = repository.send(action, from_data.to_hash)
          if model.nil?
            errors = 'Wrong username or password'
            error = { 'title' => 'Error', 'message' => errors }
            respond_with_error(repository.new, error, content_handler,
                               UNAUTHORIZED_ERROR)
          else
            write_cookie_auth(model.username)
            @response.do_redirect if content_handler == :to_html
          end
        else
          respond_with_error(repository.new, from_data.error, content_handler,
                             UNPROCESSABLE_ENTITY_ERROR)
        end
      end
    end

    class Session < Collection
      include Resources::ReadWriteProtected

      def allowed_methods
        ['GET']
      end

      private

      def collection_uri
        base_uri + 'sessions/new'
      end

      def title
        'You are now logged in'
      end
    end

    class EndSession < Collection
      include Resources::ReadWriteProtected

      def allowed_methods
        ['GET', 'POST']
      end

      def process_post
        response.set_cookie(auth_cookie_name, nil, path: '/')
        response.headers['Location'] = base_uri
        response.do_redirect
        true
      end

      private

      def collection_uri
        base_uri + 'sessions/end'
      end

      def title
        'Confirm logout'
      end

      def collection
        CollectionJSON.generate_for(collection_uri) do |builder|
          builder.set_version('1.0')
          builder.set_template
        end
      end
    end
  end
end
