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
      expect(response_body).to have_json_size(2).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  post "http://project-octopus.org/works" do
    let(:accept_header) { "text/html" }
    let(:content_type) { "application/x-www-form-urlencoded" }
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Posting a work as www-form with no data", :document => false do
      do_request

      expect(status).to eq(422)
    end
  end

  raw_form_posts = [
    "name=Title&creator=creator&license=&dateCreated=2015"
  ]

  raw_form_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/works" do
      parameter :name, "Title"
      parameter :url, "URL"

      let(:accept_header) { "text/html" }
      let(:content_type) { "application/x-www-form-urlencoded" }
      let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

      let(:raw_post) { raw_post }

      example "Posting a work as www-form #{index}", :document => false do
        do_request

        expect(response_headers).to include("Location")

        expect(status).to eq(303)
      end
    end
  end
end

resource "Work" do
  header "Accept", :accept_header
  header "Content-Type", :content_type
  header "Authorization", :authorization

  get "http://project-octopus.org/works/1" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting a creative work" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(2).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/works/1/history" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting a creative work's history" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(2).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/works/1/template" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Getting a creative work's template" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).not_to have_json_path("collection/items")
      expect(response_body).to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  raw_form_posts = [
    "name=Title&creator=creator&license=&dateCreated=2015"
  ]

  raw_form_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/works/1/template" do
      parameter :name, "Title"
      parameter :url, "URL"

      let(:accept_header) { "text/html" }
      let(:content_type) { "application/x-www-form-urlencoded" }
      let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

      let(:raw_post) { raw_post }

      example "Posting a work as www-form #{index}", :document => false do
        do_request

        expect(response_headers).to include("Location")

        expect(status).to eq(303)
      end
    end
  end

  get "http://project-octopus.org/works/1/itempages" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Getting a creative work's itempages form" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).not_to have_json_path("collection/items")
      expect(response_body).to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  raw_form_posts = [
    "name=Title&publisher=publisher&license=&url=http%3A%2F%2Fexample.com%2Fpub"
  ]

  raw_form_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/works/1/itempages" do

      let(:accept_header) { "text/html" }
      let(:content_type) { "application/x-www-form-urlencoded" }
      let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

      let(:raw_post) { raw_post }

      example "Posting a work itempage as www-form #{index}", :document => false do
        do_request

        expect(response_headers).to include("Location")

        expect(status).to eq(303)
      end
    end
  end
end
