require 'octopodes/db'
require 'octopodes/domain/thing'

module Octopodes
  module Domain
    # Domain to model a Schema.org CreativeWork
    class CreativeWork < Thing
      set_allowed_columns :name, :description, :license, :url,
                          :creator, :date_created, :publisher,
                          :is_based_on_url, :associated_media

      set_prompts name: 'Title', url: 'URL', uuid: 'ID',
                  associated_media: 'Media File URL'

      set_data_columns :uuid, :name, :description, :license, :creator,
                       :date_created, :reviewed_by, :last_reviewed

      set_link_columns :url, :associated_media, :is_based_on_url,
                       :part_of, :example_of

      many_to_one :is_part_of, class: self
      one_to_many :has_part, class: self, key: :is_part_of_id

      many_to_one :example_of_work, class: self
      one_to_many :work_example, class: self, key: :example_of_work_id

      def validate
        super
        validates_max_length 2048, :is_based_on_url, allow_blank: true
        validates_format(/\A#{URI.regexp}\z/, :is_based_on_url,
                         message: 'is not a valid URL', allow_blank: true)

        validates_max_length 2048, :associated_media, allow_blank: true
        validates_format(/\A#{URI.regexp}\z/, :associated_media,
                         message: 'is not a valid URL', allow_blank: true)
      end

      def part_of
        is_part_of.href unless is_part_of.nil?
      end

      def example_of
        example_of_work.href unless example_of_work.nil?
      end
    end
  end
end
