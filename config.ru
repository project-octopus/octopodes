require 'webmachine/adapter'
require 'webmachine/adapters/rack'
if File.file?('config/environments/development.rb')
  require File.join(File.dirname(__FILE__), 'config/environments/development.rb')
else
  require File.join(File.dirname(__FILE__), 'environments/default.rb')
end
require File.join(File.dirname(__FILE__), 'app')

run App.adapter
