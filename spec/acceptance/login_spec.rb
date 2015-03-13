require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Login' do
  header 'Authorization', :authorization

  get 'https://project-octopus.org/login' do
    example 'Authenticating with no authorization', document: false do
      load(:users)
      do_request

      expect(response_body).to include('Please try again')
      expect(response_body).not_to include('Account')

      expect(status).to eq(401)
    end
  end

  get 'https://project-octopus.org/login' do
    let(:authorization) { 'Basic ' + Base64.encode64('user1:oldpass').strip }

    example 'Authenticating with old password', document: false do
      load(:users)
      do_request

      expect(response_body).to include('Please try again')

      expect(status).to eq(401)
    end
  end

  get 'https://project-octopus.org/login' do
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    example 'Authenticating correctly', document: false do
      load(:users)
      do_request

      expect(response_body).to include('Thank you for logging in')
      expect(response_body).not_to include('Registration')
      expect(response_body).not_to include('Login')

      expect(status).to eq(200)
    end
  end
end
