require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Web Pages' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type
  header 'Authorization', :authorization

  get 'https://project-octopus.org/schema/web-pages' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting all web pages' do
      models = load(:web_pages)
      s = models.count

      do_request

      body = parse_json(response_body)
      href = body['collection']['href']

      expect(response_body).to have_json_path('collection')
      expect(response_body).to have_json_path('collection/items')
      expect(response_body).to have_json_size(s).at_path('collection/items')

      expect(href).to eq 'https://project-octopus.org/schema/web-pages/'

      expect(status).to eq(200)
    end
  end

  get 'https://project-octopus.org/schema/web-pages?limit=1' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting all web pages with limit of 1', document: false do
      load(:web_pages)

      do_request
      expect(response_body).to have_json_path('collection/links')
      expect(response_body).to have_json_size(1).at_path('collection/items')
    end
  end

  post 'https://project-octopus.org/schema/web-pages' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:content_type) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    let(:raw_post) do
      '{"template":{"data":[{"name": "name", "value": "Title"}, '\
      '{"name": "url", "value": "http://example.org/web"}]}}'
    end

    example 'Creating a new web page' do
      load(:web_pages)
      load(:users)

      do_request

      expect(response_headers).to include('Location')

      expect(status).to eq(201)
    end
  end
end

resource 'Web Page' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type
  header 'Authorization', :authorization

  get 'https://project-octopus.org/schema/web-pages/:uuid' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting one web page' do
      wb = load(:web_page__wb)
      load(:web_pages)

      do_request(uuid: wb.uuid)

      body = parse_json(response_body)
      href = body['collection']['href']
      item_href = body['collection']['items'].first['href']

      expect(response_body).to have_json_path('collection')
      expect(response_body).to have_json_path('collection/items')
      expect(response_body).to have_json_size(1).at_path('collection/items')

      expect(href).to eq 'https://project-octopus.org/schema/web-pages/'
      expect(item_href).to eq 'https://project-octopus.org/schema/web-pages/' + wb.uuid

      expect(status).to eq(200)
    end

    example 'Getting a non-existant page', document: false do
      load(:web_pages)

      do_request(uuid: '44446401-2e13-47ac-90b8-547937ec254b')

      expect(status).to eq(404)
    end

    example 'Getting a page with a non-valid UUID', document: false do
      load(:web_pages)

      do_request(uuid: 'xxx')

      expect(status).to eq(404)
    end
  end

  put 'https://project-octopus.org/schema/web-pages/:uuid' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:content_type) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    let(:raw_post) do
      '{"template":{"data":[{"name": "name", "value": "Title"}, '\
      '{"name": "url", "value": "http://example.org/web"}]}}'
    end

    example 'Updating a web page' do
      wa = load(:web_page__wa)

      do_request(uuid: wa.uuid)

      expect(status).to eq(204)
    end
  end

  get 'https://project-octopus.org/schema/web-pages/:uuid/template' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    example 'Getting a web page template' do
      wa = load(:web_page__wa)

      do_request(uuid: wa.uuid)

      expect(response_body).to have_json_path('collection/template')

      expect(status).to eq(200)
    end
  end
end
