RACK_ENV = ENV['RACK_ENV'] || 'development' unless defined? RACK_ENV

if File.file?("config/environments/#{RACK_ENV}.rb")
  require File.join(File.dirname(__FILE__), "environments/#{RACK_ENV}.rb")
else
  require File.join(File.dirname(__FILE__), 'environments/default.rb')
end

require File.join(File.dirname(__FILE__), '../app.rb')
