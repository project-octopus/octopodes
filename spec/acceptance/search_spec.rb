require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Search' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type

  get 'https://project-octopus.org/search' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting the query template' do
      do_request

      expect(response_body).to have_json_path('collection')
      expect(response_body).not_to have_json_path('collection/items')
      expect(response_body).to have_json_path('collection/queries')

      expect(status).to eq(200)
    end
  end

  get 'https://project-octopus.org/search?text=example' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Searching for records' do
      load(:creative_works)
      load(:web_pages)
      do_request

      expect(response_body).to have_json_path('collection')
      expect(response_body).to have_json_path('collection/items')
      expect(response_body).to have_json_path('collection/queries')

      expect(status).to eq(200)
    end
  end
end
