require 'webmachine'
require 'webmachine/adapters/rack'
require 'json'
require 'collection-json'

class CollectionJsonResource < Webmachine::Resource
  def content_types_provided
    [["application/collection+json", :to_json]]
  end

  def content_types_accepted
    [["application/collection+json", :from_json]]
  end

  private
  def params
    JSON.parse(request.body.to_s)
  end
end

class WorksResource < CollectionJsonResource
  def allowed_methods
    ["GET", "POST"]
  end

  def base_uri
    @request.base_uri.to_s + 'works'
  end

  def resource_exists?
    true
  end

  def to_json
    collection = CollectionJSON.generate_for(base_uri) do |builder|
    end

    collection.to_json
  end
end

class WorkResource < CollectionJsonResource
  def allowed_methods
    ["GET"]
  end

  def id
    request.path_info[:id]
  end

  def base_uri
    @request.base_uri.to_s + 'works'
  end

  def resource_exists?
    true
  end

  def to_json
    collection = CollectionJSON.generate_for(base_uri) do |builder|
    end

    collection.to_json
  end
end

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :Rack
  end
  app.routes do
    add ["works"], WorksResource
    add ["works", :id], WorkResource
    #add ['trace', '*'], Webmachine::Trace::TraceResource
  end
end
