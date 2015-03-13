require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Login' do
  get 'https://project-octopus.org/login' do
    example 'Requesting login page', document: false do
      do_request

      location = 'https://project-octopus.org/sessions/'
      expect(response_headers['Location']).to eq location
      expect(status).to eq(301)
    end
  end
end
