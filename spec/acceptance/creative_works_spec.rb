require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Creative Works' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type
  header 'Authorization', :authorization
  header 'Cookie', :cookie

  get 'https://project-octopus.org/schema/creative-works' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    example 'Getting all creative works' do
      models = load(:creative_works)
      s = models.count

      do_request

      body = parse_json(response_body)
      href = body['collection']['href']

      expect(response_body).to have_json_path('collection')
      expect(response_body).to have_json_path('collection/items')
      expect(response_body).to have_json_size(s).at_path('collection/items')

      expect(href).to eq 'https://project-octopus.org/schema/creative-works/'

      expect(status).to eq(200)
    end
  end

  get 'https://project-octopus.org/schema/creative-works?limit=1' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    example 'Getting all creative works with limit of 1', document: false do
      load(:creative_works)

      do_request
      expect(response_body).to have_json_path('collection/links')
      expect(response_body).to have_json_size(1).at_path('collection/items')
    end
  end

  get 'https://project-octopus.org/schema/creative-works/template' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    example 'Getting a creative work template' do
      load(:users)
      do_request

      expect(response_body).to have_json_path('collection/template')

      expect(status).to eq(200)
    end
  end

  post 'https://project-octopus.org/schema/creative-works' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:content_type) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    let(:raw_post) do
      '{"template":{"data":[{"name": "name", "value": "Title"}, '\
      '{"name": "url", "value": "http://example.org/web"}]}}'
    end

    example 'Creating a new creative work' do
      load(:creative_works)
      load(:users)

      do_request

      expect(response_headers).to include('Location')

      expect(status).to eq(201)
    end
  end

  get 'https://project-octopus.org/schema/creative-works/template' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting unauthorized template', document: false do
      do_request

      expect(response_body).to include('Please sign in')
      expect(status).to eq(401)
    end
  end

  post 'https://project-octopus.org/schema/creative-works' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:content_type) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('xxx:xxx').strip }

    let(:raw_post) do
      '{"template":{"data":[{"name": "name", "value": "Title"}, '\
      '{"name": "url", "value": "http://example.org/web"}]}}'
    end

    example 'Unauthorized creation of a new work', document: false do
      load(:creative_works)
      load(:users)

      do_request

      expect(status).to eq(401)
    end
  end
end

resource 'Creative Work' do
  header 'Accept', :accept_header
  header 'Content-Type', :content_type
  header 'Authorization', :authorization

  get 'https://project-octopus.org/schema/creative-works/:uuid' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    example 'Getting a creative work' do
      ca = load(:creative_work__ca)
      load(:creative_works)

      do_request(uuid: ca.uuid)

      body = parse_json(response_body)
      href = body['collection']['href']
      item_href = body['collection']['items'].first['href']

      expect(response_body).to have_json_path('collection')
      expect(response_body).to have_json_path('collection/items')
      expect(response_body).to have_json_size(2).at_path('collection/items')

      expect(href).to eq 'https://project-octopus.org/schema/creative-works/'
      expect(item_href).to eq 'https://project-octopus.org/schema/creative-works/' + ca.uuid

      expect(status).to eq(200)
    end

    example 'Getting a non-existant work', document: false do
      load(:creative_works)

      do_request(uuid: '44446401-2e13-47ac-90b8-547937ec254b')

      expect(status).to eq(404)
    end

    example 'Getting a work with a non-valid UUID', document: false do
      load(:creative_works)

      do_request(uuid: 'xxx')

      expect(status).to eq(404)
    end
  end

  put 'https://project-octopus.org/schema/creative-works/:uuid' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:content_type) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    let(:raw_post) do
      '{"template":{"data":[{"name": "name", "value": "Title"}, '\
      '{"name": "url", "value": "http://example.org/web"}]}}'
    end

    example 'Updating a creative work' do
      ca = load(:creative_work__ca)

      do_request(uuid: ca.uuid)

      expect(status).to eq(204)
    end
  end

  get 'https://project-octopus.org/schema/creative-works/:uuid/template' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    example 'Getting a creative work template' do
      ca = load(:creative_work__ca)

      do_request(uuid: ca.uuid)

      expect(response_body).to have_json_path('collection/template')

      expect(status).to eq(200)
    end
  end

  get 'https://project-octopus.org/schema/creative-works/:uuid/provenance' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    example 'Getting creative work provenance information' do
      cc = load(:creative_work__cc)

      do_request(uuid: cc.uuid)

      expect(response_body).to have_json_path('collection/template')
      expect(response_body).to have_json_size(2)
        .at_path('collection/template/data')

      expect(status).to eq(200)
    end
  end

  get 'https://project-octopus.org/schema/creative-works/:uuid/' do
    let(:accept_header) { 'application/vnd.collection+json' }

    example 'Getting a work with hexdigest UUID', document: false do
      cc = load(:creative_work__cc)

      do_request(uuid: cc.uuid.gsub('-', ''))

      expect(status).to eq(301)
    end
  end

  put 'https://project-octopus.org/schema/creative-works/:uuid/provenance' do
    let(:accept_header) { 'application/vnd.collection+json' }
    let(:content_type) { 'application/vnd.collection+json' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    let(:raw_post) do
      '{"template":{"data":[{"name": "is_part_of", "value": ""}, '\
      '{"name": "example_of_work", "value": ""}]}}'
    end

    example 'Updating creative work provenance information' do
      ca = load(:creative_work__ca)

      do_request(uuid: ca.uuid)

      expect(status).to eq(204)
    end
  end

  post 'https://project-octopus.org/schema/creative-works/:uuid/provenance' do
    let(:accept_header) { 'text/html' }
    let(:content_type) { 'application/x-www-form-urlencoded' }
    let(:authorization) { 'Basic ' + Base64.encode64('user1:pass1').strip }

    let(:raw_post) { 'is_part_of=&example_of_work=' }

    example 'Updating a provenance information', document: false do
      ca = load(:creative_work__ca)

      do_request(uuid: ca.uuid)

      expect(status).to eq(303)
    end
  end
end
