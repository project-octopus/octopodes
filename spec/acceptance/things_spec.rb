require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'All Records' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type

  get 'http://project-octopus.org/schema/things' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting all records' do
      models = load(:creative_works).concat(load(:web_pages))
      s = models.count

      do_request

      body = parse_json(response_body)
      href = body['collection']['href']

      expect(response_body).to have_json_path('collection')
      expect(response_body).to have_json_path('collection/items')
      expect(response_body).to have_json_size(s).at_path('collection/items')

      expect(href).to eq 'http://project-octopus.org/schema/things/'

      expect(status).to eq(200)
    end
  end
end
