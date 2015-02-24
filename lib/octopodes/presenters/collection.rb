require 'collection-json'

module Octopodes
  module Presenters
    ## Takes a Dataset and outputs it as CollectionJSON
    class Collection
      def initialize(dataset, options = {})
        @dataset = dataset
        accessorize(options)
        paginate
      end

      def to_json
        to_cj.to_json
      end

      def to_cj
        CollectionJSON.generate_for(@collection_uri) do |builder|
          builder.set_version('1.0')
          add_links_to builder, @links
          add_items_to builder if @include_items
          add_template_to builder if @include_template
          builder.set_error @error unless @error.nil?
        end
      end

      private

      def accessorize(options)
        params = {
          base_uri: '',
          collection_uri: '',
          error: nil,
          include_items: true,
          include_item_link: true,
          include_template: false,
          links: [],
          limit: nil,
          total: 0,
          startkey: nil,
          prevkey: nil
        }.merge(options)

        params.each do |key, value|
          instance_variable_set("@#{key}".to_sym, value)
        end
      end

      def links
        @links ||= []
      end

      # TODO: co-ordinate pagination strategy with Repositories
      def paginate
        if link_prev?
          start_key = URI(@collection_uri)
          start_params = [['startkey', @prevkey], ['limit', @limit]]
          start_key.query = URI.encode_www_form(start_params)
          links << { href: start_key.to_s, rel: 'previous', prompt: 'Previous' }
        end

        if link_next?
          next_key_uri = URI(@collection_uri)
          model = @dataset.last
          next_key = [model.created_at, model.identifier].join(',')
          next_params = [['startkey', next_key],
                         ['prevkey', @startkey],
                         ['limit', @limit]]
          next_key_uri.query = URI.encode_www_form(next_params)
          links << { href: next_key_uri.to_s, rel: 'next', prompt: 'Next' }
        end
      end

      def link_prev?
        !@startkey.nil? && !@startkey.empty?
      end

      def link_next?
        count = @dataset.count
        @limit && count > 0 && @total > @limit && count >= @limit
      end

      def add_links_to(item, links)
        (links || []).each do |l|
          rel = l[:rel]
          # if the url is not absolute, make it relative to the base uri
          begin
            uri = URI(l[:href])
            if uri.host.nil?
              href = @base_uri + l[:href]
            else
              href = l[:href]
              rel = 'external' unless href.start_with?(@base_uri)
            end
          rescue URI::InvalidURIError
            href = l[:href]
          end
          item.add_link href, rel, prompt: l[:prompt]
        end
      end

      def add_items_to(builder)
        @dataset.each do |model|
          builder.add_item(build_item_href(model)) do |item|
            add_data_to item, model.data
            add_links_to item, model.links
          end
        end
      end

      def add_template_to(builder)
        builder.set_template do |template|
          add_data_to template, @dataset.first.template
        end
      end

      def build_item_href(model)
        @include_item_link && model.href ? @base_uri + model.href : ''
      end

      def add_data_to(item, data)
        data.each do |datum|
          item.add_data datum.first, datum.last
        end
      end
    end
  end
end
