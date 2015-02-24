require 'rss'

module Octopodes
  module Presenters
    ## Takes a Dataset and outputs it as Atom/XML
    class Atom
      def initialize(dataset, options = {})
        @dataset = dataset
        @base_uri = options[:base_uri]
        @collection_uri = options[:collection_uri]
      end

      def to_atom
        @atom ||= RSS::Maker.make('atom') do |maker|
          maker.channel.author = 'Project Octopus'
          maker.channel.updated = Time.now.to_s
          maker.channel.about = 'Project Octopus Feed'
          maker.channel.title = 'Project Octopus'

          (@dataset || []).each do |model|
            item_id = model.uuid
            item_name = model.name ? model.name : 'Untitled'
            item_updated = model.updated_at

            begin
              host = model.url ? URI(model.url).host : nil
            rescue URI::InvalidURIError
              host = nil
            end

            item_title = item_name + (host ? " on #{host}" : '')

            item_user = model.updated_by ? model.updated_by.username : nil

            item_summary = item_user ? "Added by #{item_user}" : ''

            maker.items.new_item do |item|
              item.link = @collection_uri + item_id + '/'
              item.title = item_title
              item.description = item_summary
              item.updated = item_updated
            end
          end
        end
      end

      def to_s
        to_atom.to_s
      end
    end
  end
end
