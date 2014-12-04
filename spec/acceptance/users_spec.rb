require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Users" do
  header "Accept", :accept_header
  header "Content-Type", :content_type

  get "users" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting all users as Collection+JSON" do
      do_request

      expect(response_body).to have_json_path("collection")

      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(2).at_path("collection/items")

      expect(status).to eq(200)
    end
  end

  get "users" do
    let(:accept_header) { "text/html" }

    example "Getting all users", :document => false do
      do_request

      expect(status).to eq(200)
    end
  end

end

resource "User" do
  header "Accept", :accept_header
  header "Content-Type", :content_type
  header "Authorization", :authorization

  get "/users/:username" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:username) { "user1" }

    example "Getting a user as Collection+JSON" do
      do_request

      expect(response_body).to have_json_path("collection")

      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(1).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  get "users/:username" do
    let(:accept_header) { "text/html" }
    let(:username) { "user1" }

    example "Getting a user", :document => false do
      do_request

      expect(status).to eq(200)
    end
  end

  get "users/:username" do
    let(:username) { "xxx" }

    example "Getting a non-existent user", :document => false do
      do_request

      expect(status).to eq(404)
    end
  end

  get "/users/:username/settings" do
    let(:accept_header) { "text/html" }
    let(:username) { "user1" }

    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Getting user settings", :document => false do
      do_request

      expect(status).to eq(200)
    end
  end

  get "/users/:username/settings" do
    let(:accept_header) { "text/html" }
    let(:username) { "user1" }

    example "Getting settings and not logged in", :document => false do
      do_request

      expect(status).to eq(401)
    end
  end

  get "/users/:username/settings" do
    let(:accept_header) { "text/html" }
    let(:username) { "user0" }

    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Getting unauthorized settings", :document => false do
      do_request

      expect(status).to eq(403)
    end
  end

  post "/users/:username/settings" do

    let(:accept_header) { "text/html" }
    let(:content_type) { "application/x-www-form-urlencoded" }

    let(:username) { "user1" }

    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    let(:raw_post) { "none=none" }

    example "Updating a user's settings with no data", :document => false do
      do_request

      expect(status).to eq(422)
    end
  end

  post "/users/:username/settings" do

    let(:accept_header) { "text/html" }
    let(:content_type) { "application/x-www-form-urlencoded" }

    let(:username) { "user1" }

    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    let(:raw_post) { "password=new_password" }

    example "Updating a user's settings", :document => false do
      do_request

      expect(response_headers).to include("Location")

      expect(status).to eq(303)
    end
  end
end

