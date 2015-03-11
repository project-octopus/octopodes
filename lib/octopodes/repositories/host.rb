require 'sequel'
require 'octopodes/db'
require 'octopodes/domain/host'

module Octopodes
  module Repositories
    # Repository for Hosts
    class Host
      def self.popular(_options = {})
        hosts = DB['SELECT * FROM ('\
                   "SELECT substring(url from '.*://([^/]*)' ) as hostname, "\
                   "count(substring(url from '.*://([^/]*)' )) "\
                   'FROM things '\
                   'GROUP BY hostname ORDER BY count DESC'\
                   ') AS hostnames WHERE hostname IS NOT NULL'
                ].all
        hosts.map { |data| Domain::Host.new(data) }
      end
    end
  end
end
