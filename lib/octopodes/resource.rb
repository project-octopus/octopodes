module Octopodes
  module Resource
    # Mixin to denote a public resource
    module Public
      def must_authorize?
        false
      end
    end

    # Mixin to denote a resource with protected write access
    module Collection
      def must_authorize?
        return true if @request.post?
      end
    end

    # Mixin to denote a resource with protected read/write access
    module Template
      def must_authorize?
        true
      end
    end
  end
end
