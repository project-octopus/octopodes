require 'webmachine'
require 'webmachine/adapters/rack'

require 'octopodes/resources'

include Octopodes

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :Rack
  end
  app.routes do
    add [], Resources::Home

    # TODO: hard-code URLs to supported types, either here
    #   or in the resource
    add ['schema', :type], Resources::Things
    add ['schema', :type, 'template'], Resources::ThingsTemplate
    add ['schema', :type, :uuid], Resources::Thing
    add ['schema', :type, :uuid, 'template'], Resources::ThingTemplate

    add ['schema', :type, :uuid, 'provenance'], Resources::Provenance

    add ['hosts'], Resources::Hosts
    add ['hosts', :hostname], Resources::Host

    add ['login'], Resources::Login
    add ['sessions'], Resources::Sessions
    add ['sessions', 'new'], Resources::Session
    add ['sessions', 'end'], Resources::EndSession
    add ['signups'], Resources::Signups
    add ['signups', :token], Resources::Signup

    add ['users'], Resources::Users
    add ['users', :username], Resources::User
    add ['users', :username, 'settings'], Resources::Settings
    add ['users', :username, 'settings', :token], Resources::Setting

    add ['feed'], Resources::Feed::Feed
    add ['u', :uuid], Resources::Feed::Item
    add ['reviews', :uuid], Resources::Feed::Item

    if configatron.webmachine.trace
      add ['trace', :*], Webmachine::Trace::TraceResource
    end
  end
end
