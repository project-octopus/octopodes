require 'octopodes/resources/things'

module Octopodes
  module Resources
    # Things Template resource
    class ThingsTemplate < Things
      include Octopodes::Resources::ReadWriteProtected

      private

      def title
        'Add ' + super
      end

      def dataset
        @dataset ||= [repository.new(url: url)]
      end

      def include_template?
        true
      end

      def include_items?
        false
      end
    end

    def total
      1
    end
  end
end
