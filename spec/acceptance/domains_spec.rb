require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Domains" do
  header "Accept", :accept_header
  header "Content-Type", :content_type

  get "http://project-octopus.org/domains" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting all domains as Collection+JSON" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_path("collection/links")
      expect(response_body).to have_json_size(4).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/domains" do
    let(:accept_header) { "text/html" }

    example "Getting all domains", :document => false do
      do_request

      expect(response_body).to include("europeana.eu")
      expect(response_body).to include("flickr.com")
      expect(status).to eq(200)
    end
  end

end

resource "Domain" do
  header "Accept", :accept_header
  header "Content-Type", :content_type

  get "http://project-octopus.org/domains/:domain" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:domain) { "flickr.com" }

    example "Getting a domain as Collection+JSON" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(2).at_path("collection/items")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/domains/:domain" do
    let(:accept_header) { "text/html" }
    let(:domain) { "flickr.com" }

    example "Getting a domain", :document => false do
      do_request

      expect(response_body).to include("flickr.com")
      expect(status).to eq(200)
    end
  end
end
