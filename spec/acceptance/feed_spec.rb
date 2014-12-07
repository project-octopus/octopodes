require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Feed" do
  header "Accept", :accept_header

  get "feed" do
    let(:accept_header) { "application/atom+xml" }

    example "Getting atom feed", :document => false do
      do_request

      expect(response_body).to include("xml")
      expect(response_body).to include("Atom")
      expect(response_body).to include("title")
      expect(response_body).to include("entry")
      expect(response_body).to include("webpage0")
      expect(status).to eq(200)
    end

  end
end

resource "FeedItem" do

  get "/u/:id" do
    let(:id) { "webpage0" }

    example "Getting feed item", :document => false do
      do_request
      expect(status).to eq(307)
    end
  end

  get "/u/:id" do
    let(:id) { "xxx" }

    example "Getting non-existent feed item", :document => false do
      do_request
      expect(status).to eq(404)
    end
  end
end
