require 'octopodes/domain/web_page'
require 'octopodes/repositories/creative_work'

module Octopodes
  module Repositories
    # Repository to access WebPages
    class WebPage < CreativeWork
      def self.domain
        Domain::WebPage
      end
    end
  end
end
