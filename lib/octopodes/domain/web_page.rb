require 'octopodes/db'
require 'octopodes/domain/creative_work'

module Octopodes
  module Domain
    # Domain to model a Schema.org CreativeWork
    class WebPage < CreativeWork
      set_allowed_columns :name, :description, :license, :url,
                          :creator, :publisher, :date_published

      set_prompts name: 'Title', url: 'URL', uuid: 'ID'

      set_data_columns :uuid, :name, :description, :license,
                       :publisher, :date_published,
                       :reviewed_by, :last_reviewed

      set_link_columns :url

      def validate
        super
        validates_presence :url
      end
    end
  end
end
