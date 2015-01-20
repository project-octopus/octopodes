require 'spec_helper'
require 'rspec_api_documentation/dsl'

require 'configatron'

resource "Works" do
  header "Accept", :accept_header
  header "Content-Type", :content_type
  header "Authorization", :authorization

  get "http://project-octopus.org/works" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting all creative works" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(1).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end
end
