require 'webmachine/adapter'
require 'webmachine/adapters/rack'
if File.file?('config/environments/production.rb')
  require File.join(File.dirname(__FILE__), 'config/environments/production.rb')
else
  require File.join(File.dirname(__FILE__), 'config/environments/default.rb')
end
require File.join(File.dirname(__FILE__), 'app')

run App.adapter
