module Octopodes
  module Resources
    # Mixin to denote a public resource
    module ReadOnly
      def must_authorize?
        false
      end
    end

    # Mixin to denote a resource with protected write access
    module WriteProtected
      def must_authorize?
        return true if ['PUT', 'POST', 'DELETE'].include?(request.method)
      end
    end

    # Mixin to denote a resource with protected read/write access
    module ReadWriteProtected
      def must_authorize?
        true
      end
    end
  end
end
