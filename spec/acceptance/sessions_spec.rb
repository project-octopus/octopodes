require 'spec_helper'
require 'rspec_api_documentation/dsl'

require 'configatron'

resource 'Protected Resource' do
  header 'Accept', :accept_header
  header 'Cookie', :cookie

  get 'https://project-octopus.org/schema/creative-works/template' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:cookie)  { "_Octopodes_identity=#{username}--#{hmac}" }
    let(:username) { 'user1' }
    let(:hmac) do
      digest = OpenSSL::Digest::SHA1.new
      secret = configatron.secret_token
      OpenSSL::HMAC.hexdigest(digest, secret, username)
    end

    example 'Getting a protected resource using Cookies', document: false do
      load(:users)
      do_request
      expect(status).to eq(200)
    end
  end
end

resource 'Sessions' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type
  header 'Cookie', :cookie

  get 'https://project-octopus.org/sessions' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting a login page', document: false do
      do_request
      expect(response_body).to have_json_path('collection')

      expect(response_body).to have_json_path('collection/template')
      expect(response_body).to have_json_path('collection/template/data')
      expect(response_body).to have_json_size(2)
        .at_path('collection/template/data')

      expect(status).to eq(200)
    end
  end

  post 'https://project-octopus.org/sessions' do
    let(:accept_header) { 'text/html' }
    let(:content_type) { 'application/x-www-form-urlencoded' }

    let(:raw_post) { 'username=user1&password=pass1' }

    let(:set_cookie)  do
      "_Octopodes_identity=#{username}--#{hmac}; HttpOnly; Path=/"
    end
    let(:username) { 'user1' }
    let(:hmac) do
      digest = OpenSSL::Digest::SHA1.new
      secret = configatron.secret_token
      OpenSSL::HMAC.hexdigest(digest, secret, username)
    end

    example 'Logging in via www-form', document: false do
      load(:users)
      do_request

      expect(response_headers).to include('Location')
      expect(response_headers).to include('Set-Cookie')
      expect(response_headers['Set-Cookie']).to eq set_cookie

      location = 'https://project-octopus.org/sessions/new/'
      expect(response_headers['Location']).to eq location
      expect(status).to eq(303)
    end
  end
end

resource 'New Session' do
  header 'Accept', :accept_header
  header 'Cookie', :cookie

  get 'https://project-octopus.org/sessions/new' do
    let(:accept_header) { 'text/html' }

    let(:cookie)  { "_Octopodes_identity=#{username}--#{hmac}" }
    let(:username) { 'user1' }
    let(:hmac) do
      digest = OpenSSL::Digest::SHA1.new
      secret = configatron.secret_token
      OpenSSL::HMAC.hexdigest(digest, secret, username)
    end

    example 'Getting login confirmation', document: false do
      load(:users)
      do_request

      expect(status).to eq(200)
    end
  end
end

resource 'End Session' do
  header 'Accept', :accept_header
  header 'Cookie', :cookie

  get 'https://project-octopus.org/sessions/end' do
    let(:accept_header) { 'text/html' }

    let(:cookie)  { "_Octopodes_identity=#{username}--#{hmac}" }
    let(:username) { 'user1' }
    let(:hmac) do
      digest = OpenSSL::Digest::SHA1.new
      secret = configatron.secret_token
      OpenSSL::HMAC.hexdigest(digest, secret, username)
    end

    example 'Getting logout page', document: false do
      load(:users)
      do_request

      expect(status).to eq(200)
    end
  end

  post 'https://project-octopus.org/sessions/end' do
    let(:accept_header) { 'text/html' }
    let(:set_cookie)  { '_Octopodes_identity=; Path=/' }

    let(:accept_header) { 'text/html' }

    let(:cookie)  { "_Octopodes_identity=#{username}--#{hmac}" }
    let(:username) { 'user1' }
    let(:hmac) do
      digest = OpenSSL::Digest::SHA1.new
      secret = configatron.secret_token
      OpenSSL::HMAC.hexdigest(digest, secret, username)
    end

    example 'Logging out', document: false do
      load(:users)
      do_request

      expect(status).to eq(303)

      expect(response_headers).to include('Set-Cookie')
      expect(response_headers['Set-Cookie']).to eq set_cookie
    end
  end
end
