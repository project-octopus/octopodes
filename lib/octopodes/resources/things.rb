require 'octopodes/resources/collection'
require 'octopodes/presenters/collection'
require 'octopodes/presenters/collection_template'
require 'octopodes/presenters/www_form'

module Octopodes
  module Resources
    # Things resource
    class Things < Collection
      include Octopodes::Resources::WriteProtected

      def allowed_methods
        ['GET', 'POST']
      end

      # Check if Repositories module has a class by this name
      def resource_exists?
        Repositories.constants.include?(class_symbol)
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
        class_title == 'Things' ? 'All Records' : class_title
      end

      # TODO: Add a separate option for some kind of `form_action` or `post_uri`
      #   instead of relying on `collection_uri` to always play this role. This
      #   only matters for HTML output.
      def collection_uri
        @collection_uri ||= base_uri + 'schema/' + type + '/'
      end

      def create_id
        @create_id ||= repository.uuid
      end

      def dataset
        @dataset ||= repository.recent(limit: limit, startkey: startkey)
      end

      def total
        @total ||= repository.count
      end

      def links
        @links = []
        @links << { href: base_uri + 'schema/things/',
                    rel: 'things', prompt: 'All Records' }

        if class_title == 'Things'
          @links << { href: base_uri + 'schema/creative-works/',
                      rel: 'creative-works', prompt: 'Creative Works' }
          @links << { href: base_uri + 'schema/web-pages/',
                      rel: 'web-pages', prompt: 'Web Pages' }
        else
          @links << { href: collection_uri,
                      rel: 'things', prompt: class_title }

          unless @user.nil?
            @links << { href: collection_uri + 'template/', rel: 'template',
                        prompt: "Add a #{class_title.singularize}" }
          end
        end

        @links << { href: base_uri + 'search/',
                    rel: 'queries', prompt: 'Search' }

        @links
      end

      def include_template?
        @include_template.nil? ? false : @include_template
      end

      def include_items?
        @include_items.nil? ? true : @include_items
      end

      def collection
        options = { base_uri: base_uri, collection_uri: collection_uri,
                    include_items: include_items?,
                    include_template: include_template?,
                    links: links, error: @error, limit: limit, total: total,
                    startkey: startkey, prevkey: prevkey }
        Presenters::Collection.new(dataset, options).to_cj
      end

      def url
        @request.query['url']
      end

      # Path which names a dasherized Schema.org Type
      def type
        @request.path_info[:type]
      end

      # Turn the type into a Class name
      #   "creative-works" => "CreativeWork"
      def class_name
        @class_name ||= type.underscore.classify
      end

      # Turn the type into a Class title
      #   "creative-works" => "Creative Works"
      def class_title
        @class_title ||= type.titleize
      end

      # Turn the type in to a symbol
      #   "creative-works" => :CreativeWork
      def class_symbol
        @class_symbol ||= class_name.to_sym
      end

      # Get the class for this type
      def repository
        @repository ||= Repositories.module_eval(class_name)
      end
    end
  end
end
