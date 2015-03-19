require 'octopodes/resources/user'
require 'octopodes/repositories/audit'

module Octopodes
  module Resources
    # Edits Resource
    class Edits < User
      private

      def title
        count = audits.count
        "#{count} latest edits by #{username}"
      end

      def collection
        # TODO: paginate results
        uri = collection_uri + username + '/edits/'
        CollectionJSON.generate_for(uri) do |builder|
          builder.set_version('1.0')
          (links || []).each do |l|
            builder.add_link l[:href], l[:rel], prompt: l[:prompt]
          end
          audits.each do |a|
            a_href = base_uri + 'u/' + a[:uuid]
            builder.add_item(a_href) do |item|
              item.add_data 'name', prompt: 'Title', value: a[:name]
              item.add_data 'updated_at', prompt: 'Date', value: a[:updated_at]
            end
          end
        end
      end

      def audits
        options = { limit: limit }
        user = dataset.first
        @audits ||= Repositories::Audit.find_by_user(user, options)
      end

      def limit
        100
      end

      def links
        [{ href: collection_uri + username + '/',
           rel: 'up', prompt: 'User Profile' }]
      end
    end
  end
end
