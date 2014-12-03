require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Login" do
  header "Accept", :accept_header
  header "Content-Type", :content_type
  header "Authorization", :authorization

  get "login" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Authenticating with no authorization", :document => false do
      do_request

      expect(status).to eq(401)
    end
  end

  get "login" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:authorization) { "Basic " + Base64.encode64("user1:oldpass").strip }

    example "Authenticating with old password", :document => false do
      do_request

      expect(status).to eq(401)
    end
  end

  get "login" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Authenticating correctly", :document => false do
      do_request

      expect(status).to eq(200)
    end
  end
end
