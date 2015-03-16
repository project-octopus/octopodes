require 'configatron'
require 'collection-json'
require 'json'

require 'octopodes/resources/base_resource'

module Octopodes
  module Resources
    # Collection Resource
    class Collection < BaseResource
      UNAUTHORIZED_ERROR = 401
      UNPROCESSABLE_ENTITY_ERROR = 422

      def content_types_provided
        [['text/html', :to_html],
         ['application/vnd.collection+json', :to_cj]]
      end

      def content_types_accepted
        [['application/x-www-form-urlencoded', :from_urlencoded],
         ['application/vnd.collection+json', :from_cj]]
      end

      def base_uri
        @request.base_uri.to_s
      end

      def to_html
        Views::Collection.new(collection, title, menu, body).render
      end

      def to_cj
        JSON.pretty_generate(collection.to_hash)
      end

      def trace?
        configatron.webmachine.trace
      end

      private

      def title
        'Reviewing the Use of Creative Works, One URL at a Time'
      end

      def body; end

      def collection
        CollectionJSON.generate_for(base_uri) do |builder|
          builder.set_version('1.0')
        end
      end

      def startkey
        @request.query['startkey']
      end

      def prevkey
        @request.query['prevkey']
      end

      def limit
        min, max, default = 1, 500, 10
        req = @request.query['limit']
        (req =~ /^\d+$/) ? [min, [req.to_i, max].min].max : default
      end

      def links
        []
      end

      # Generic method for processing and responding to request data. The
      # `repo` is a Repositories class, and `action` names a method to accept
      # the data, while `from_data` contains the input data and can respond
      # to `valid?`, `error`, and `to_hash`. The `content_handler` names the
      # resource method to respond with the correct content type. The `id` is
      # a uuid that identifies the created resource.
      def process_data(action, repo, id, from_data, content_handler)
        if from_data.valid?
          model = repo.send(action, id, from_data.to_hash, @user)
          if model.valid?
            @response.do_redirect if content_handler == :to_html
          else
            respond_with_model_error(model, content_handler)
          end
        else
          respond_with_error(repository.new, from_data.error, content_handler,
                             UNPROCESSABLE_ENTITY_ERROR)
        end
      end

      def respond_with_model_error(model, content_handler)
        errors = model.errors.full_messages.join(', ')
        error = { 'title' => 'Bad Input', 'message' => errors }
        @include_template = true
        @include_items = false
        respond_with_error(model, error, content_handler,
                           UNPROCESSABLE_ENTITY_ERROR)
      end

      def respond_with_error(model, error, content_handler, code)
        @dataset = [model]
        @error = error
        @response.body = send(content_handler)
        @response.code = code
      end
    end
  end
end
