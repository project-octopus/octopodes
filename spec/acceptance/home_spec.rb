require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'API Entry Point' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type
  header 'Authorization', :authorization

  get 'http://project-octopus.org/' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting home resource' do
      do_request

      expect(response_body).to have_json_path('collection')
      expect(status).to eq(200)
    end
  end
end
