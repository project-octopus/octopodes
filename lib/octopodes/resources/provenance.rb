require 'octopodes/resources/collection'

module Octopodes
  module Resources
    # Provenance resource
    class Provenance < Thing
      include Octopodes::Resources::ReadWriteProtected

      def allowed_methods
        ['GET', 'POST', 'PUT']
      end

      def post_is_create?
        false
      end

      def from_cj
        template = Presenters::CollectionTemplateDecoder.new(request.body.to_s)
        process_data(:update_provenance, repository, uuid, template, :to_cj)
      end

      def from_urlencoded
        form = Presenters::WwwFormDecoder.new(request.body.to_s)
        process_data(:update_provenance, repository, uuid, form, :to_html)
      end

      def process_post
        form = Presenters::WwwFormDecoder.new(request.body.to_s)
        @response.headers['Location'] = collection_uri + uuid + '/'
        process_data(:update_provenance, repository, uuid, form, :to_html)
      end

      private

      def title
        'Provenance information for the Work'
      end

      def collection
        model = dataset.first
        uri = collection_uri + uuid + '/provenance/'
        CollectionJSON.generate_for(uri) do |builder|
          builder.set_version('1.0')
          (links || []).each do |l|
            builder.add_link l[:href], l[:rel], prompt: l[:prompt]
          end
          builder.set_template do |t|
            part = model.is_part_of ? model.is_part_of.uuid : nil
            example = model.example_of_work ? model.example_of_work.uuid : nil

            part_prompt = 'Part of a Larger Work (Octopus ID)'
            example_prompt = 'Example/Instance/Realization/Derivation of '\
                             'a Work (Octopus ID)'
            t.add_data 'is_part_of', prompt: part_prompt, value: part
            t.add_data 'example_of_work', prompt: example_prompt, value: example
          end
        end
      end

      def dataset
        @dataset ||= repository.find(uuid)
      end

      def links
        @links = []
        @links << { href: collection_uri + uuid + '/', prompt: 'View' }
      end
    end
  end
end
