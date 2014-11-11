require_relative '../app'

require 'rspec_api_documentation'
require 'json_spec'
require 'json'

Reviews.instance.database = 'collection-data-works-test'

RspecApiDocumentation.configure do |config|
  config.app = Webmachine::Adapters::Rack.new(App.configuration, App.dispatcher)
end

RSpec.configure do |config|
  config.include JsonSpec::Helpers

  config.before do
  end
end

