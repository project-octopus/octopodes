require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Hosts' do
  header 'Accept', :accept_header

  get 'https://project-octopus.org/hosts/' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Listing web hosts listed by popularity' do
      load(:creative_works)
      load(:web_pages)
      do_request

      expect(response_body).to have_json_path('collection')
      expect(response_body).to have_json_path('collection/items')
      expect(response_body).to have_json_size(2).at_path('collection/items')

      body = parse_json(response_body)
      href = body['collection']['href']
      expect(href).to eq 'https://project-octopus.org/hosts/'

      expect(status).to eq(200)
    end
  end
end

resource 'Host' do
  header 'Accept', :accept_header

  get 'https://project-octopus.org/hosts/:hostname' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:hostname) { 'example.org' }

    example 'Getting all records for a host' do
      load(:creative_works)
      load(:web_pages)
      do_request

      expect(response_body).to have_json_path('collection')
      expect(response_body).to have_json_path('collection/items')
      expect(response_body).to have_json_size(2).at_path('collection/items')

      expect(status).to eq(200)
    end
  end
end
