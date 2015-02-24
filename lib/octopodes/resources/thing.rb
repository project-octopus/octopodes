require 'uuidtools'

require 'octopodes/resources/things'

module Octopodes
  module Resources
    # Thing resource
    class Thing < Things
      def allowed_methods
        ['GET', 'POST', 'PUT']
      end

      def resource_exists?
        super && hyphenated_uuid? && dataset.count > 0
      end

      def previously_existed?
        !nil_uuid? && dataset.count > 0
      end

      # Redirect to the correct format of the UUID
      def moved_permanently?
        collection_uri + uuid + '/'
      end

      def post_is_create?
        false
      end

      def from_cj
        template = Presenters::CollectionTemplateDecoder.new(request.body.to_s)
        process_data(:update, uuid, template, :to_cj)
      end

      def from_urlencoded
        form = Presenters::WwwFormDecoder.new(request.body.to_s)
        process_data(:update, uuid, form, :to_html)
      end

      def process_post
        form = Presenters::WwwFormDecoder.new(request.body.to_s)

        # Set the collection uri to the current resource. If the model saves,
        #  we redirect back here. However, if it fails, the form `action` will
        #  point here instead of the base collection uri.
        @collection_uri = base_uri + 'schema/' + type + '/' + uuid + '/'
        @response.headers['Location'] = @collection_uri

        process_data(:update, uuid, form, :to_html)
      end

      private

      def title
        @dataset.first.name ? @dataset.first.name : super
      end

      def dataset
        @dataset ||= repository.find_with_parts(uuid)
      end

      def links
        @links = []

        if class_title == 'Things'
          @links << { href: base_uri + 'schema/things/',
                      rel: 'things', prompt: 'All Records' }
        else
          @links << { href: collection_uri,
                      rel: 'things', prompt: class_title }

          unless @user.nil?
            @links << { href: collection_uri + uuid + '/' + 'template/',
                        rel: 'template', prompt: 'Edit' }
            @links << { href: collection_uri + uuid + '/' + 'provenance/',
                        rel: 'template', prompt: 'Provenance' }
          end
        end

        @links
      end

      def uuid_path
        @request.path_info[:uuid]
      end

      def uuid
        @uuid ||= uuid_tool.to_s
      end

      def uuid_tool
        UUIDTools::UUID.parse(uuid_path)
      rescue ArgumentError
        UUIDTools::UUID.parse_hexdigest(uuid_path)
      end

      def nil_uuid?
        @nil_uuid ||= uuid_tool.nil_uuid?
      end

      def hyphenated_uuid?
        (uuid_path =~ /^([a-f\d]{8}(-[a-f\d]{4}){3}-[a-f\d]{12}?)$/i) == 0
      end
    end
  end
end
