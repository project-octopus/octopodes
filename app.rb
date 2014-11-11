require 'webmachine'
require 'webmachine/adapters/rack'
require 'json'
require 'collection-json'

require_relative 'lib/records'
require_relative 'lib/templates'

class CollectionResource < Webmachine::Resource
  def content_types_provided
    [["text/html", :to_html],
     ["application/vnd.collection+json", :to_cj]]
  end

  def content_types_accepted
    [["application/x-www-form-urlencoded", :from_urlencoded],
     ["application/vnd.collection+json", :from_cj]]
  end

  def trace?
    true
  end

  private
  def include_template?
    true
  end

  def collection
    @collection ||= CollectionJSON.generate_for(base_uri) do |builder|
      builder.set_version("1.0")
      (documents["rows"] || []).each do |row|
        doc = row["value"]
        item_id = doc["_id"]
        item_uri = base_uri + "#{item_id}"
        builder.add_item(item_uri) do |item|
          if doc.key?("hasPart")
            part = doc["hasPart"]
            if part.key?("name")
              item.add_data "name", prompt: "Title", value: part["name"]
            end
            if part.key?("creator")
              item.add_data "creator", prompt: "Creator", value: part["creator"]
            end
            if part.key?("license")
              item.add_data "license", prompt: "License", value: part["license"]
            end
          end
          if doc.key?("lastReviewed")
              item.add_data "date", prompt: "Date", value: doc["lastReviewed"]
          end
          item.add_link doc["url"], "full", prompt: "URL"
        end
      end
      if include_template?
        builder.set_template do |template|
          template.add_data "name", prompt: "Title"
          template.add_data "creator", prompt: "Creator"
          template.add_data "license", prompt: "License"
          template.add_data "url", prompt: "URL"
        end
      end
      unless @error.nil?
        builder.set_error @error
      end
    end
  end
end

class ReviewsResource < CollectionResource
  def allowed_methods
    ["GET", "POST"]
  end

  def malformed_request?
    false
  end

  def base_uri
    @request.base_uri.to_s + 'reviews/'
  end

  def resource_exists?
    true
  end

  def post_is_create?
    true
  end

  def create_path
    @create_path ||= Database.instance.uuid
  end

  def to_html
    CollectionTemplate.new(collection).render
  end

  def to_cj
    collection.to_json
  end

  def from_cj
    begin
      cj_raw = '{"collection":' + request.body.to_s + '}'
      cj_doc = CollectionJSON.parse(cj_raw)

      if !cj_doc.template.nil? && !cj_doc.template.data.nil?
        data = cj_doc.template.data

        nd = data.find { |d| d.name === "name" }
        name = !nd.nil? ? nd.value : nil

        ud = data.find { |d| d.name === "url" }
        url = !ud.nil? ? ud.value : nil

        cd = data.find { |d| d.name === "creator" }
        creator = !cd.nil? ? cd.value : nil

        ld = data.find { |d| d.name === "license" }
        license = !ld.nil? ? ld.value : nil

        rev = Reviews.instance.create(create_path, url, name, creator, license)
        unless rev["error"].nil?
          @error = {"title" => rev["error"], "message" => rev["reason"]}
        end
      else
        @error = {"title" => "Bad Input", "message" => "Missing template data"}
      end
    rescue JSON::ParserError
      @error = {"title" => "Bad Input", "message" => "Malformed Collection+JSON"}
    end

    unless @error.nil?
      @response.body = to_cj
      @response.code = 422 # Unprocessable Entity
    end
  end

  def from_urlencoded
    data = URI::decode_www_form(request.body.to_s)
    name = data.assoc('name') ? data.assoc('name').last : nil
    creator = data.assoc('creator') ? data.assoc('creator').last : nil
    license = data.assoc('license') ? data.assoc('license').last : nil
    url = data.assoc('url') ? data.assoc('url').last : nil
    rev = Reviews.instance.create(create_path, url, name, creator, license)

    if rev["ok"] === true
      # Clients (e.g., web browsers) submitting urlencoded data should
      # redirect to the newly created resource, since they won't act on
      # a 201 Created response.
      @response.do_redirect
    end

    unless rev["error"].nil?
      @error = {"title" => rev["error"], "message" => rev["reason"]}
      @response.body = to_html
      @response.code = 422 # Unprocessable Entity
    end
  end

  private

  def documents
    @documents ||= Reviews.instance.all
  end
end

class ReviewResource < CollectionResource
  def allowed_methods
    ["GET"]
  end

  def base_uri
    @request.base_uri.to_s + 'reviews/'
  end

  def resource_exists?
    !(documents["rows"].nil? || documents["rows"].empty?)
  end

  def to_html
    CollectionTemplate.new(collection).render
  end

  def to_cj
    collection.to_json
  end

  private

  def include_template?
    false
  end

  def id
    request.path_info[:id]
  end

  def documents
    @documents ||= Reviews.instance.find(id)
  end

end

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :Rack
  end
  app.routes do
    add ["reviews"], ReviewsResource
    add ["reviews", :id], ReviewResource
    add ['trace', '*'], Webmachine::Trace::TraceResource
  end
end
