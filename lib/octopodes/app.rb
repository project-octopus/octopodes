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

    add ['schema', 'things'], Resources::Things, type: 'things'

    creative_work_types = ['creative-works', 'web-pages']

    creative_work_types.each do |type|
      add ['schema', type], Resources::Things, type: type
      add ['schema', type, 'template'], Resources::ThingsTemplate, type: type
      add ['schema', type, :uuid], Resources::Thing, type: type
      add ['schema', type, :uuid, 'template'], Resources::ThingTemplate,
          type: type
    end

    add ['schema', 'creative-works', :uuid, 'provenance'],
        Resources::Provenance, type: 'creative-works'

    add ['search'], Resources::Search

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
