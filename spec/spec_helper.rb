ENV['RACK_ENV'] = 'test'
RACK_ENV = 'test'

require File.join(File.dirname(__FILE__), '../config/boot')

require 'rspec_api_documentation'
require 'json_spec'
require 'json'

require 'rake'

RspecApiDocumentation.configure do |config|
  config.app = Webmachine::Adapters::Rack.new(App)
  config.format = :html
  config.docs_dir = Pathname.new("public/docs/api")
end

RSpec.configure do |config|
  config.include JsonSpec::Helpers

  config.before(:all) do
    load 'Rakefile'
    capture_stdout {Rake.application['octopus:db:delete'].invoke('test')}
    capture_stdout {Rake.application['octopus:db:delete'].reenable}
    capture_stdout {Rake.application['octopus:db:create'].invoke('test')}
    capture_stdout {Rake.application['octopus:db:create'].reenable}
    capture_stdout {Rake.application['octopus:db:fixtures'].invoke('test')}
    capture_stdout {Rake.application['octopus:db:fixtures'].reenable}
  end

  config.after(:all) do
    capture_stdout {Rake.application['octopus:db:delete'].invoke('test')}
    capture_stdout {Rake.application['octopus:db:delete'].reenable}
  end
end

# Capture the output from the rake tasks so they don't disturb viewing tests
def capture_stdout
  s = StringIO.new
  oldstdout = $stdout
  $stdout = s
  yield
  s.string
ensure
  $stdout = oldstdout
end
