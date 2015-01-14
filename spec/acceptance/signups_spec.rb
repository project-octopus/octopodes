require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Signups" do
  header "Accept", :accept_header
  header "Content-Type", :content_type

  get "http://project-octopus.org/signups" do
    let(:accept_header) { "application/vnd.collection+json" }

    example "Getting the signup form as Collection+JSON" do
      do_request

      expect(response_body).to have_json_path("collection")

      expect(response_body).to have_json_path("collection/template")
      expect(response_body).to have_json_path("collection/template/data")
      expect(response_body).to have_json_size(2).at_path("collection/template/data")

      expect(status).to eq(200)
    end
  end

  get "http://project-octopus.org/signups" do
    let(:accept_header) { "text/html" }

    example "Getting the signup form", :document => false do
      do_request

      expect(status).to eq(200)
    end
  end

  bad_raw_posts = [
    '', '{}', '{"template":{}}', '{"template":{"data":[]}}',
    '{"template":{"data":[{"name": "n", "val": "v"}]}}',
    '{"template":{"data":[{"name": "whatever", "value": "wrong"}]}}',
    '{"template":{"data":[{"name": "username", "value": "no_password"}]}}',
    '{"template":{"data":[{"name": "password", "value": "no_username"}]}}'
  ]

  bad_raw_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/signups" do
      let(:accept_header) { "application/vnd.collection+json" }
      let(:content_type) { "application/vnd.collection+json" }

      let(:raw_post) { raw_post }

      example "Registering a user as Collection+JSON with bad input #{index}", :document => false  do
        do_request

        expect(response_body).to have_json_path("collection")
        expect(response_body).to have_json_path("collection/error")

        expect(status).to eq(422)
      end
    end
  end

  post "http://project-octopus.org/signups" do

    let(:accept_header) { "application/vnd.collection+json" }
    let(:content_type) { "application/vnd.collection+json" }

    let(:raw_post) { '{"template":{"data":[{"name": "username", "value": "bad user name"}, {"name": "password", "value": "a password"}]}}' }

    example "Registering a user with a bad name", :document => false do
      do_request

      expect(status).to eq(422)
    end
  end

  post "http://project-octopus.org/signups" do

    let(:accept_header) { "application/vnd.collection+json" }
    let(:content_type) { "application/vnd.collection+json" }

    let(:raw_post) { '{"template":{"data":[{"name": "username", "value": "user1"}, {"name": "password", "value": "a password"}]}}' }

    example "Registering a user with a reserved name", :document => false do
      do_request

      expect(status).to eq(422)
    end
  end

  post "http://project-octopus.org/signups" do

    let(:accept_header) { "application/vnd.collection+json" }
    let(:content_type) { "application/vnd.collection+json" }

    let(:raw_post) { '{"template":{"data":[{"name": "username", "value": "newuser"}, {"name": "password", "value": "new password"}]}}' }

    example "Registering a user as Collection+JSON" do
      do_request

      expect(response_headers).to include("Location")

      expect(status).to eq(201)
    end
  end

  post "http://project-octopus.org/signups" do

    let(:accept_header) { "text/html" }
    let(:content_type) { "application/x-www-form-urlencoded" }

    let(:raw_post) { "username=anotheruser&password=new%20password" }

    example "Registering a user with www-form", :document => false do
      do_request

      expect(response_headers).to include("Location")

      expect(status).to eq(303)
    end
  end

  post "http://project-octopus.org/signups" do

    let(:accept_header) { "text/html" }
    let(:content_type) { "application/x-www-form-urlencoded" }

    let(:raw_post) { "username=uniquename&password=" }

    example "Registering a user missing password with www-form", :document => false do
      do_request

      expect(response_body).to include("uniquename")
      expect(status).to eq(422)
    end
  end

  bad_form_posts = ['', 'test', 'test=', 'username=']

  bad_form_posts.each_with_index do |raw_post, index|

    post "http://project-octopus.org/signups" do
      let(:accept_header) { "text/html" }
      let(:content_type) { "application/x-www-form-urlencoded" }

      let(:raw_post) { raw_post }

      example "Registering a user with bad input #{index}", :document => false  do
        do_request

        expect(status).to eq(422)
      end
    end
  end

end

resource "Signup" do
  header "Accept", :accept_header
  header "Content-Type", :content_type

  get "http://project-octopus.org/signups/:identity" do
    let(:accept_header) { "text/html" }
    let(:identity) { "identity2" }

    example "Getting the signup message", :document => false do
      do_request

      expect(status).to eq(200)
    end
  end
end
