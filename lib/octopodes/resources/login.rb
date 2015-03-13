require 'octopodes/resources/collection'

module Octopodes
  module Resources
    # Login Resource
    class Login < Collection
      def resource_exists?
        false
      end

      def previously_existed?
        true
      end

      def moved_permanently?
        base_uri + 'sessions/'
      end
    end
  end
end
