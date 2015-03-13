require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Feed' do
  header 'Accept', :accept_header

  get 'https://project-octopus.org/feed' do
    let(:accept_header) { 'application/atom+xml' }

    example 'Getting atom feed', document: false do
      cc = load(:creative_work__cc)
      do_request

      expect(response_body).to include('xml')
      expect(response_body).to include('Atom')
      expect(response_body).to include('title')
      expect(response_body).to include('entry')
      expect(response_body).to include(cc.uuid)
      expect(status).to eq(200)
    end
  end
end

resource 'FeedItem' do
  get 'https://project-octopus.org/u/:uuid' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting feed item', document: false do
      ca = load(:creative_work__ca)
      do_request(uuid: ca.uuid)
      expect(status).to eq(307)
    end
  end

  get 'https://project-octopus.org/u/:id' do
    example 'Getting non-existent feed item', document: false do
      do_request(uuid: 'xxx')
      expect(status).to eq(404)
    end
  end
end
