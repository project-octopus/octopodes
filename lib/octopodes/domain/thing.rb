require 'securerandom'
require 'octopodes/db'
require 'octopodes/domain/cti'
require 'octopodes/domain/user'
require 'octopodes/domain/base'

module Octopodes
  module Domain
    # Domain to model a Schema.org Thing, the top-level object in the
    #   type hierarchy.
    class Thing < Sequel::Model
      include Base
      include CTI

      set_allowed_columns :name, :description, :license, :url

      # TODO: Make these available to subclasses if not re-defined
      set_prompts url: 'URL'

      set_data_columns :name, :description, :license, :reviewed_by, :updated_at

      set_link_columns :url

      plugin :class_table_inheritance, key: :type

      plugin :timestamps, update_on_create: true

      plugin :validation_helpers

      many_to_one :updated_by, class: User

      def before_create
        self.uuid ||= SecureRandom.uuid
        super
      end

      def validate
        super
        validates_presence :name unless is_a?(WebPage)

        validates_unique :uuid
        validates_max_length 2048, :url, allow_blank: true
        validates_format(/\A#{URI.regexp}\z/, :url,
                         message: 'is not a valid URL', allow_blank: true)
      end

      def identifier
        uuid
      end

      # Formulate an href for this model using the class name and uuid
      #
      #   Thing.create(name: 'A').href # "schema/things/cad36401..."
      def href
        base = 'schema/' + self.class.to_s.demodulize.tableize.dasherize + '/'
        base + identifier if identifier
      end

      def reviewed_by
        updated_by.username if updated_by
      end

      alias_method :last_reviewed, :updated_at
    end
  end
end
