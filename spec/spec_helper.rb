ENV['RACK_ENV'] = 'test'
RACK_ENV = 'test'

require File.join(File.dirname(__FILE__), '../config/boot')

require 'rspec_api_documentation'
require 'json_spec'
require 'json'

require 'fixture_dependencies'
require 'fixture_dependencies/rspec/sequel'

fixture_path = File.join(File.dirname(__FILE__), '../db/fixtures')
FixtureDependencies.fixture_path = fixture_path

RspecApiDocumentation.configure do |config|
  config.app = Webmachine::Adapters::Rack.new(App)
  config.format = :html
  config.docs_dir = Pathname.new('public/docs/api')
end

RSpec.configure do |config|
  config.include JsonSpec::Helpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.backtrace_exclusion_patterns.concat([
    %r{\/lib\d*\/gems\/},
    %r{spec\/spec_helper}])

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end

  Octopodes::Domain::User.plugin :secure_password, cost: 4
end
