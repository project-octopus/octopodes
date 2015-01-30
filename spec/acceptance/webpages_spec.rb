require 'spec_helper'
require 'rspec_api_documentation/dsl'

require 'configatron'

resource "Webpage" do
  header "Accept", :accept_header
  header "Content-Type", :content_type
  header "Authorization", :authorization

  get "http://project-octopus.org/webpages/1" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting a web page" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(1).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/webpages/1/history" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting a web page's history" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(2).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/webpages/1/template" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Getting a web pages's template" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).not_to have_json_path("collection/items")
      expect(response_body).to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  raw_form_posts = [
    "name=Title&license=&url=http%3A%2F%2Fexample.org%2Fitempage"
  ]

  raw_form_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/webpages/1/template" do
      parameter :name, "Title"
      parameter :url, "URL"

      let(:accept_header) { "text/html" }
      let(:content_type) { "application/x-www-form-urlencoded" }
      let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

      let(:raw_post) { raw_post }

      example "Updating a webpage as www-form #{index}", :document => false do
        do_request

        expect(response_headers).to include("Location")

        expect(status).to eq(303)
      end
    end
  end
end
