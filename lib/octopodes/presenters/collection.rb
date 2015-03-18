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

      def to_hash
        @to_hash ||= to_cj.to_hash
      end

      def to_json
        @to_json ||= to_cj.to_json
      end

      def to_cj
        @cj ||= CollectionJSON.generate_for(@collection_uri) do |builder|
          builder.set_version('1.0')
          add_links_to builder, @links
          add_items_to builder if @include_items
          add_queries_to builder
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
          queries: [],
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

      def add_link(link)
        links << link
      end

      def queries
        @queries ||= []
      end

      # TODO: co-ordinate pagination strategy with Repositories
      def paginate
        if link_prev?
          start_key = URI(@collection_uri)
          start_params = [['startkey', @prevkey], ['limit', @limit]]
          start_params.concat(query_params)
          start_key.query = URI.encode_www_form(start_params)
          add_link(href: start_key.to_s, rel: 'previous', prompt: 'Previous')
        end

        if link_next?
          next_key_uri = URI(@collection_uri)
          model = @dataset.last
          next_key = [model.created_at, model.identifier].join(',')
          next_params = [['startkey', next_key],
                         ['prevkey', @startkey],
                         ['limit', @limit]]
          next_params.concat(query_params)
          next_key_uri.query = URI.encode_www_form(next_params)
          add_link(href: next_key_uri.to_s, rel: 'next', prompt: 'Next')
        end
      end

      # Any query templates with a non-blank value are transformed into
      # parameter pairs for use in pagination.
      def query_params
        @query_params ||= queries.map { |q| q[:data] }
                          .flatten(1)
                          .select { |d| data_has_value?(d) }
                          .map { |d| [d.first, d.last[:value]] }
      end

      def data_has_value?(d)
        d.count == 2 && !d.last[:value].nil? && !d.last[:value].empty?
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

      def add_queries_to(builder)
        queries.each do |q|
          builder.add_query(q[:href], q[:rel], prompt: q[:prompt]) do |query|
            (q[:data] || []).each do
              add_data_to(query, q[:data])
            end
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
