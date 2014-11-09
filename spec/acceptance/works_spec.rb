require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Works" do

  before (:all) do
  end

  after (:all) do
  end

  header "Accept", "application/collection+json"
  header "Content-Type", "application/collection+json"

  get "works" do

    example "Getting all works" do
      do_request

      expect(status).to eq(200)
    end
  end

end

resource "Work" do

  before (:all) do
  end

  before (:all) do
  end

  header "Accept", "application/collection+json"
  header "Content-Type", "application/collection+json"

  get "/works/work1" do

    example "Getting a work" do
      do_request

      expect(status).to eq(200)
    end
  end
end

