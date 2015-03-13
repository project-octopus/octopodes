RACK_ENV = ENV['RACK_ENV'] || 'development' unless defined? RACK_ENV

require File.join(File.dirname(__FILE__), 'environment')

# Generate a secret token
begin
  require File.join(File.dirname(__FILE__), 'secret_token')
rescue Exception => e
  require 'securerandom'
  open(File.join(File.dirname(__FILE__), 'secret_token.rb'), 'w+') do |f|
    f.puts <<-"EOS"
require 'configatron'
configatron.secret_token = "#{SecureRandom.hex(20)}"
EOS
    f.flush
  end
  require File.join(File.dirname(__FILE__), 'secret_token')
end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
if File.exist?(ENV['BUNDLE_GEMFILE'])
  require 'bundler/setup'
  Bundler.require
end

if defined?(I18n)
  I18n.enforce_available_locales = false
end

require 'octopodes'
