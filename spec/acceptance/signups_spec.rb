require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Signups' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type

  get 'http://project-octopus.org/signups' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting the signup form' do
      do_request

      expect(response_body).to have_json_path('collection')

      expect(response_body).to have_json_path('collection/template')
      expect(response_body).to have_json_path('collection/template/data')
      expect(response_body).to have_json_size(2).at_path('collection/template/data')

      expect(status).to eq(200)
    end
  end

  post 'http://project-octopus.org/signups' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:content_type) { 'application/vnd.collection+json' }

    let(:raw_post) do
      '{"template":{"data":[{"name": "username", "value": "user1"}, '\
      '{"name": "password", "value": "a password"}]}}'
    end

    example 'Registering a user with a reserved name', document: false do
      load(:users)
      do_request

      expect(status).to eq(422)
    end
  end

  post 'http://project-octopus.org/signups' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:content_type) { 'application/vnd.collection+json' }

    let(:raw_post) do
      '{"template":{"data":[{"name": "username", "value": "newuser"}, '\
      '{"name": "password", "value": "new password"}]}}'
    end

    example 'Registering a user' do
      do_request

      expect(response_headers).to include('Location')

      expect(status).to eq(201)
    end
  end

  post 'http://project-octopus.org/signups' do
    let(:accept_header) { 'text/html' }
    let(:content_type) { 'application/x-www-form-urlencoded' }

    let(:raw_post) { 'username=anotheruser&password=new%20password' }

    example 'Registering a user with www-form', document: false do
      do_request

      expect(response_headers).to include('Location')

      expect(status).to eq(303)
    end
  end

  post 'http://project-octopus.org/signups' do
    let(:accept_header) { 'text/html' }
    let(:content_type) { 'application/x-www-form-urlencoded' }

    let(:raw_post) { 'username=uniquename&password=' }

    example 'Registering a user missing password with www-form',
            document: false do
      do_request

      expect(response_body).to include('uniquename')
      expect(status).to eq(422)
    end
  end
end

resource 'Signup' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type

  get 'http://project-octopus.org/signups/:token' do
    let(:accept_header) { 'text/html' }
    let(:token) { 'e2436dc4-291c-4c84-b0f9-7f7c980123de' }

    example 'Getting the signup message', document: false do
      load(:users)
      do_request

      expect(status).to eq(200)
    end
  end
end
