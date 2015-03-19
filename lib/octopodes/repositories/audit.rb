require 'octopodes/db'

module Octopodes
  module Repositories
    # Repository to access audit records
    class Audit
      def self.find_by_user(user, options = {})
        limit = options[:limit]
        if exists?
          DB["SELECT row_data->'id' AS id, "\
             "       row_data->'type' AS type, "\
             '       action_tstamp_tx AS updated_at, '\
             "       row_data->'uuid' AS uuid, "\
             "       row_data->'updated_by_id' AS updated_by_id, "\
             "       row_data->'name' as name "\
             'FROM audit.logged_actions '\
             "WHERE row_data->'updated_by_id'= '?' "\
             'ORDER by action_tstamp_tx DESC '\
             'limit ?', user.id, limit].all
        else
          []
        end
      end

      def self.exists?
        audit = DB['SELECT EXISTS( SELECT 1 '\
                   'FROM information_schema.tables '\
                   'WHERE '\
                   "table_schema = 'audit' AND "\
                   "table_name = 'logged_actions' )"].first

        audit[:exists]
      end
    end
  end
end
