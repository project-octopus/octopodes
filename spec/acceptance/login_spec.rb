require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Login" do
  header "Authorization", :authorization

  get "login" do

    example "Authenticating with no authorization", :document => false do
      do_request

      expect(response_body).to include("Please try again")

      expect(status).to eq(401)
    end
  end

  get "login" do
    let(:authorization) { "Basic " + Base64.encode64("user1:oldpass").strip }

    example "Authenticating with old password", :document => false do
      do_request

      expect(response_body).to include("Please try again")

      expect(status).to eq(401)
    end
  end

  get "login" do
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Authenticating correctly", :document => false do
      do_request

      expect(response_body).to include("Thank you for logging in")
      expect(response_body).not_to include("Registration")
      expect(response_body).not_to include("Login")

      expect(status).to eq(200)
    end
  end
end
