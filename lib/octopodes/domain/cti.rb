module Octopodes
  module Domain
    # Support methods when using the class table inheritance sequel plugin
    module CTI
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def type
          bare_class_name
        end

        # The demodularized name of the class, so
        # `Octopodes::Domain::Thing` becomes `Thing`
        def bare_class_name
          name.split('::').last
        end
      end

      # By default, the plugin uses the fully qualified class name including
      #   the module. Instead, use the bare class name.
      def before_create
        self.type = self.class.type
        super
      end
    end
  end
end
