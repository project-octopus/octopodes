require 'octopodes/resources/collection'
require 'octopodes/repositories/user'

module Octopodes
  module Resources
    # Signups Resource
    class Signups < Collection
      def allowed_methods
        ['GET', 'POST']
      end

      def collection_uri
        base_uri + 'signups/'
      end

      def post_is_create?
        true
      end

      def create_path
        collection_uri + create_id
      end

      def from_cj
        template = Presenters::CollectionTemplateDecoder.new(request.body.to_s)
        process_data(:create, repository, create_id, template, :to_cj)
      end

      def from_urlencoded
        form = Presenters::WwwFormDecoder.new(request.body.to_s)
        process_data(:create, repository, create_id, form, :to_html)
      end

      private

      def title
        'Sign up for Project Octopus'
      end

      def create_id
        @create_id ||= repository.token
      end

      def dataset
        @dataset ||= [repository.new]
      end

      def collection
        options = { base_uri: base_uri, collection_uri: collection_uri,
                    include_items: false,
                    include_template: true,
                    links: links, error: @error }
        Presenters::Collection.new(dataset, options).to_cj
      end

      def repository
        Repositories::User
      end
    end

    # Signup Resource
    class Signup < Collection
      def allowed_methods
        ['GET']
      end

      def collection_uri
        base_uri + 'signups/'
      end

      def resource_exists?
        token_valid? && dataset.count > 0
      end

      private

      def token
        request.path_info[:token]
      end

      def token_valid?
        (token =~ /^([a-f\d]{8}(-[a-f\d]{4}){3}-[a-f\d]{12}?)$/i) == 0
      end

      def title
        'Sign-up Submitted'
      end

      def collection
        options = { base_uri: base_uri, collection_uri: collection_uri,
                    include_items: false, include_template: false }
        Presenters::Collection.new(dataset, options).to_cj
      end

      def dataset
        @dataset ||= [repository.identify(token)]
      end

      def repository
        Repositories::User
      end
    end
  end
end
