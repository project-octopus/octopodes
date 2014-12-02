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

end

