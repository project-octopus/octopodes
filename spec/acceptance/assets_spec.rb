require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Assets" do
  header "Content-Type", :content_type

  get "favicon.ico" do
    let(:accept_header) { "image/x-icon" }

    example "Getting the favicon", :document => false do
      do_request

      expect(status).to eq(200)
    end
  end

  get "assets/empty" do
    let(:accept_header) { "*/*" }

    example "Getting an asset", :document => false do
      do_request

      expect(status).to eq(200)
    end
  end

  get "assets/xxx" do
    let(:accept_header) { "*/*" }

    example "Getting a non-existent asset", :document => false do
      do_request

      expect(status).to eq(404)
    end
  end
end
