require 'webmachine'
require 'webmachine/adapters/rack'
require 'json'
require 'collection-json'
require 'configatron'

require 'octopodes/resources'

include Octopodes::Resources

Datastore.connect(configatron.octopus.database)

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :Rack
  end
  app.routes do
    add [], HomeResource

    add ['works'], WorksResource
    add ['works;template'], WorksTemplateResource
    add ['works', :id], WorkResource
    add ['works', :id, 'history'], WorkHistoryResource
    add ['works', :id, 'webpages'], WorkWebPagesResource, source: :webpages
    add ['works', :id, 'webpages', :add], WorkResource
    add ['works', :id, 'elements'], WorkWebPagesResource, source: :elements
    add ['works', :id, 'template'], WorkTemplateResource
    add ['works', :id, 'template', :edit], WorkResource

    add ['webpages', :id], WebPageResource, source: :webpages
    add ['webpages', :id, 'history'], WebPageHistoryResource, source: :webpages
    add ['webpages', :id, 'template'], WebPageTemplateResource,
        source: :webpages
    add ['webpages', :id, 'template', :edit], WebPageResource, source: :webpages

    add ['elements', :id], WebPageResource, source: :elements
    add ['elements', :id, 'history'], WebPageHistoryResource, source: :elements
    add ['elements', :id, 'template'], WebPageTemplateResource,
        source: :elements
    add ['elements', :id, 'template', :edit], WebPageResource, source: :elements

    add ['reviews'], ReviewsResource
    add ['reviews;template'], ReviewsTemplateResource
    add ['reviews;queries'], ReviewsResource, queries: true
    add ['reviews', :id], ReviewResource

    add ['domains'], DomainsResource
    add ['domains', :domain], DomainResource
    add ['domains', :domain, :id], FeedItemResource

    add ['signups'], SignupsResource
    add ['signups', :token], SignupResource
    add ['users'], UsersResource
    add ['users', :username], UserResource
    add ['users', :username, 'settings'], IdentitiesResource
    add ['users', :username, 'settings', :setting], IdentityResource
    add ['login'], LoginResource

    add ['feed'], FeedResource
    add ['u', :id], FeedItemResource

    if configatron.webmachine.trace
      add ['trace', :*], Webmachine::Trace::TraceResource
    end
  end
end
