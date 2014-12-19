require 'spec_helper'
require 'rspec_api_documentation/dsl'

require 'configatron'

resource "Reviews" do
  header "Accept", :accept_header
  header "Content-Type", :content_type
  header "Authorization", :authorization

  before (:all) do
  end

  after (:all) do
  end

  get "http://project-octopus.org/reviews" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting all reviews as Collection+JSON" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_path("collection/links")
      expect(response_body).to have_json_size(2).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/reviews;template" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Getting reviews template as Collection+JSON" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).not_to have_json_path("collection/items")
      expect(response_body).to have_json_path("collection/template")
      expect(response_body).to have_json_path("collection/template/data")
      expect(response_body).to have_json_size(7).at_path("collection/template/data")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/reviews;template" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting unauthorized reviews template", :document => false do
      do_request

      expect(response_body).to include("Please sign in")
      expect(status).to eq(401)
    end
  end

  bad_raw_posts = [
    '', '{}', '{"template":{}}', '{"template":{"data":[]}}',
    '{"template":{"data":[{"name": "n", "val": "v"}]}}',
    '{"template":{"data":[{"name": "url", "value": "http/ not a url"}]}}',
    '{"template":{"data":[{"name": "url", "value": "http://example.com"},{"name": "isBasedOnUrl", "value": "http/ not a url"}]}}',
    '{"template":{"data":[{"name": "url", "value": "http://example.com"},{"name": "contentUrl", "value": "http/ not a url"}]}}',
    '{"template":{"data":[{"name": "whatever", "value": "wrong"}]}}'
  ]

  bad_raw_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/reviews" do
      let(:accept_header) { "application/vnd.collection+json" }
      let(:content_type) { "application/vnd.collection+json" }
      let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

      let(:raw_post) { raw_post }

      example "Posting a review as Collection+JSON with bad input #{index}", :document => false  do
        do_request

        expect(response_body).to have_json_path("collection")
        expect(response_body).to have_json_path("collection/error")

        expect(status).to eq(422)
      end
    end
  end

  post "http://project-octopus.org/reviews" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:content_type) { "application/vnd.collection+json" }
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    let(:raw_post) { '{"template":{"data":[{"name": "name", "value": "Title"}, {"name": "url", "value": "http://example.org/web"}]}}' }

    example "Posting a review as Collection+JSON" do
      do_request

      expect(response_headers).to include("Location")

      expect(status).to eq(201)
    end
  end

  ["reviews", "reviews;template"].each do |post_review_url|

    post post_review_url  do
      let(:accept_header) { "application/vnd.collection+json" }
      let(:content_type) { "application/vnd.collection+json" }

      let(:raw_post) { '{"template":{"data":[{"name": "name", "value": "Title"}, {"name": "url", "value": "http://example.org/web"}]}}' }

      example "Posting to #{post_review_url} without authorization", :document => false do
        do_request

        expect(status).to eq(401)
      end
    end
  end

  get "http://project-octopus.org/reviews" do
    let(:accept_header) { "text/html" }

    example "Getting all reviews", :document => false do
      do_request

      expect(response_body).not_to include("template")
      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/reviews;template?url=http%3A%2F%2Ftestquery.org%2Ftest" do
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }
    let(:accept_header) { "text/html" }

    example "Getting review template", :document => false do
      do_request

      expect(response_body).to include("http://testquery.org/test")
      expect(status).to eq(200)
    end
  end

  post "http://project-octopus.org/reviews" do
    let(:accept_header) { "text/html" }
    let(:content_type) { "application/x-www-form-urlencoded" }
    let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

    example "Posting a review as www-form with no data", :document => false do
      do_request

      expect(status).to eq(422)
    end
  end

  bad_form_posts = ['', 'test', 'test=', 'url=']

  bad_form_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/reviews" do
      let(:accept_header) { "text/html" }
      let(:content_type) { "application/x-www-form-urlencoded" }
      let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

      let(:raw_post) { raw_post }

      example "Posting a review with bad input #{index}", :document => false  do
        do_request

        expect(status).to eq(422)
      end
    end
  end

  raw_form_posts = [
    "url=http%3A%2F%2FURL.com&name=Some+Title&creator=&license=&is_based_on_url=",
    "url=http%3A%2F%2FURL.org%2Fabc&name=Moros%2C+Zaragoza%2C+Espa%C3%B1a&creator=&license=&is_based_on_url="
  ]

  raw_form_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/reviews" do
      parameter :name, "Title"
      parameter :url, "URL"

      let(:accept_header) { "text/html" }
      let(:content_type) { "application/x-www-form-urlencoded" }
      let(:authorization) { "Basic " + Base64.encode64("user1:pass1").strip }

      let(:raw_post) { raw_post }

      example "Posting a review as www-form #{index}", :document => false do
        do_request

        expect(response_headers).to include("Location")

        expect(status).to eq(303)
      end
    end
  end

end

resource "Review" do
  header "Accept", :accept_header
  header "Content-Type", :content_type

  before (:all) do
  end

  before (:all) do
  end

  get "http://project-octopus.org/reviews/:id" do
    let(:accept_header) { "application/vnd.collection+json" }
    let(:id) { "webpage0" }

    example "Getting a review as Collection+JSON" do
      do_request

      expect(response_body).to have_json_path("collection")
      expect(response_body).to have_json_path("collection/items")
      expect(response_body).to have_json_size(1).at_path("collection/items")
      expect(response_body).not_to have_json_path("collection/template")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/reviews/:id" do
    let(:id) { "xxx" }

    example "Getting a non-existent item", :document => false do
      do_request

      expect(status).to eq(404)
    end
  end

  get "http://project-octopus.org/reviews/:id" do
    let(:accept_header) { "text/html" }
    let(:id) { "webpage0" }

    example "Getting a review when not logged in", :document => false do
      do_request

      expect(response_body).not_to include("template")
      expect(status).to eq(200)
    end
  end

end
