require 'rspec/core/rake_task'
require 'net/http'
require 'configatron'

require_relative 'lib/couch.rb'

namespace :octopus do

  namespace :db do
    desc "Create a database"
    task :create, :environment do |t, args|
      environment = args[:environment] || 'default'
      load "config/environments/#{environment}.rb"

      database = configatron.octopus.database
      uri = URI(database)

      password = !uri.password.nil? ? URI::decode(uri.password) : nil

      server = Couch::Server.new(uri.scheme, uri.host, uri.port, uri.user, password)
      response = server.put(uri.path, nil)

      case response.code.to_s
      when "201", "202"
        design_doc = File.read("db/design-doc.json")
        server.put("#{uri.path}/_design/all", design_doc)
        puts "Created #{database}"
      when "412"
        puts "The database #{database} already exists"
      else
        puts "There was a problem creating #{database}"
        puts response.body
      end

    end

    desc "Add test data to a database"
    task :fixtures, :environment do |t, args|
      environment = args[:environment] || 'default'
      load "config/environments/#{environment}.rb"

      database = configatron.octopus.database
      uri = URI(database)

      password = !uri.password.nil? ? URI::decode(uri.password) : nil

      server = Couch::Server.new(uri.scheme, uri.host, uri.port, uri.user, password)

      fixtures = File.read("db/fixtures.json")
      response = server.post("#{uri.path}/_bulk_docs", fixtures)

      case response.code.to_s
      when "201", "202"
        puts "Added test data to #{database}"
      else
        puts "There was a problem loading test data into #{database}"
        puts response.body
      end
    end

    desc "Delete a database"
    task :delete, :environment do |t, args|
      environment = args[:environment] || 'default'
      load "config/environments/#{environment}.rb"

      database = configatron.octopus.database
      uri = URI(database)

      password = !uri.password.nil? ? URI::decode(uri.password) : nil

      server = Couch::Server.new(uri.scheme, uri.host, uri.port, uri.user, password)
      response = server.delete(uri.path)

      case response.code.to_s
      when "200", "202"
        puts "Deleted #{database}"
      when "404"
        puts "The database #{database} doesn't exist"
      else
        puts "There was a problem deleting #{database}"
        puts response.body
      end
    end
  end

end

desc 'Generate API request documentation from API specs'
RSpec::Core::RakeTask.new('docs:generate') do |t|
  t.pattern = 'spec/acceptance/**/*_spec.rb'
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter"]
end
