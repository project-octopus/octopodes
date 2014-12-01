require 'spec_helper'
require 'rspec_api_documentation/dsl'

require 'configatron'

require_relative '../../lib/records'

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

      expect(response_body).to have_json_path("collection/template")
      expect(response_body).to have_json_path("collection/template/data")
      expect(response_body).to have_json_size(2).at_path("collection/template/data")

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

  bad_raw_posts = [
    '', '{}', '{"template":{}}', '{"template":{"data":[]}}',
    '{"template":{"data":[{"name": "n", "val": "v"}]}}',
    '{"template":{"data":[{"name": "whatever", "value": "wrong"}]}}'
  ]

  bad_raw_posts.each_with_index do |raw_post, index|

    post "users" do
      let(:accept_header) { "application/vnd.collection+json" }
      let(:content_type) { "application/vnd.collection+json" }

      let(:raw_post) { raw_post }

      example "Creating a user as Collection+JSON with bad input #{index}", :document => false  do
        do_request

        expect(response_body).to have_json_path("collection")
        expect(response_body).to have_json_path("collection/error")

        expect(status).to eq(422)
      end
    end
  end

  post "users" do

    let(:accept_header) { "application/vnd.collection+json" }
    let(:content_type) { "application/vnd.collection+json" }

    let(:raw_post) { '{"template":{"data":[{"name": "username", "value": "user1"}, {"name": "password", "value": "a password"}]}}' }

    example "Creating a user with a registered name", :document => false do
      do_request

      expect(status).to eq(422)
    end
  end

  post "users" do

    let(:accept_header) { "application/vnd.collection+json" }
    let(:content_type) { "application/vnd.collection+json" }

    let(:raw_post) { '{"template":{"data":[{"name": "username", "value": "newuser"}, {"name": "password", "value": "new password"}]}}' }

    example "Creating a user as Collection+JSON" do
      do_request

      expect(response_headers).to include("Location")

      expect(status).to eq(201)
    end
  end

  post "users" do

    let(:accept_header) { "text/html" }
    let(:content_type) { "application/x-www-form-urlencoded" }

    let(:raw_post) { "username=anotheruser&password=new%20password" }

    example "Creating a user with www-form", :document => false do
      do_request

      expect(response_headers).to include("Location")

      expect(status).to eq(303)
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

