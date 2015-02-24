require 'rspec/core/rake_task'
require 'configatron'

RACK_ENV = ENV.fetch('RACK_ENV', 'development') unless defined? RACK_ENV

require File.join(File.dirname(__FILE__), 'config/environment')

namespace :db do
  desc 'Run migrations'
  task :migrate, [:version] do |_t, args|
    require 'sequel'
    Sequel.extension :migration
    db = Sequel.connect(configatron.sequel.database)
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, 'db/migrations', target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      Sequel::Migrator.run(db, 'db/migrations')
    end
  end

  desc 'Add fixtures'
  task :fixtures, [:version] do |_t|
    require 'sequel'
    Sequel.connect(configatron.sequel.database)

    require 'fixture_dependencies'
    require 'octopodes/domain'

    include Octopodes::Domain

    fixture_path = File.join(File.dirname(__FILE__), 'db/fixtures')
    FixtureDependencies.fixture_path = fixture_path
    FixtureDependencies.load(:creative_works)
    FixtureDependencies.load(:web_pages)
    FixtureDependencies.load(:users)
  end

  desc 'Import CouchDB data to PostgreSQL'
  task :import do |_t|
    require 'sequel'
    require_relative 'lib/couch/server'
    require_relative 'db/couch/migrations.rb'
    db = Sequel.connect(configatron.sequel.database)
    couch = configatron.octopus.database

    CouchMigrations.import(db, couch)
  end
end

desc 'Generate API request documentation from API specs'
RSpec::Core::RakeTask.new('docs:generate') do |t|
  t.pattern = 'spec/acceptance/**/*_spec.rb'
  t.rspec_opts = ['--format RspecApiDocumentation::ApiFormatter']
end
