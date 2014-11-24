env_config = File.expand_path('../config/environments/test.rb', File.dirname(__FILE__))
app_config = File.expand_path('../config/environments/default.rb', File.dirname(__FILE__))

if File.file?(env_config)
  require env_config
else
  require app_config
end

require_relative '../app'

require 'rspec_api_documentation'
require 'json_spec'
require 'json'

RspecApiDocumentation.configure do |config|
  config.app = Webmachine::Adapters::Rack.new(App.configuration, App.dispatcher)
  config.format = :markdown
end

RSpec.configure do |config|
  config.include JsonSpec::Helpers

  config.before do
  end
end

