require 'sequel'
require 'configatron'

DB = Sequel.connect(configatron.sequel.database)

# Silently ignore unallowed model parameters rather than raising an Error.
Sequel::Model.strict_param_setting = false

Sequel.extension :blank
Sequel.extension :inflector
DB.extension :pg_hstore

audit = DB['SELECT EXISTS( SELECT 1 '\
           'FROM information_schema.tables '\
           'WHERE '\
           "table_schema = 'audit' AND "\
           "table_name = 'logged_actions' )"].first

if audit[:exists]
  if configatron.sequel.audit
    DB.run("SELECT audit.audit_table('users', 'true', 'false')")
    DB.run("SELECT audit.audit_table('things', 'true', 'false')")
    DB.run("SELECT audit.audit_table('creative_works', 'true', 'false')")
    DB.run("SELECT audit.audit_table('web_pages', 'true', 'false')")
  else
    DB.run('DROP TRIGGER IF EXISTS audit_trigger_row ON users')
    DB.run('DROP TRIGGER IF EXISTS audit_trigger_stm ON users')
    DB.run('DROP TRIGGER IF EXISTS audit_trigger_row ON things')
    DB.run('DROP TRIGGER IF EXISTS audit_trigger_stm ON things')
    DB.run('DROP TRIGGER IF EXISTS audit_trigger_row ON creative_works')
    DB.run('DROP TRIGGER IF EXISTS audit_trigger_stm ON creative_works')
    DB.run('DROP TRIGGER IF EXISTS audit_trigger_row ON web_pages')
    DB.run('DROP TRIGGER IF EXISTS audit_trigger_stm ON web_pages')
  end
end
