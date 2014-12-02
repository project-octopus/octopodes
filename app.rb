require 'webmachine'
require 'webmachine/adapters/rack'
require 'json'
require 'collection-json'
require 'configatron'
require 'filemagic'

require_relative 'lib/records'
require_relative 'lib/templates'

I18n.config.enforce_available_locales = true

WebPages.instance.database = configatron.octopus.database
Users.instance.database = configatron.octopus.database

class CollectionResource < Webmachine::Resource
  def content_types_provided
    [["text/html", :to_html],
     ["application/vnd.collection+json", :to_cj]]
  end

  def content_types_accepted
    [["application/x-www-form-urlencoded", :from_urlencoded],
     ["application/vnd.collection+json", :from_cj]]
  end

  def base_uri
    @request.base_uri.to_s + '/'
  end

  def to_html
    CollectionTemplate.new(collection, title).render
  end

  def to_cj
    collection.to_json
  end

  def trace?
    configatron.webmachine.trace
  end

  private
  def title
    "Welcome to Project Octopus"
  end

  def collection
    CollectionJSON.generate_for(base_uri) do |builder|
      builder.set_version("1.0")
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

  def post_is_create?
    true
  end

  def create_path
    @create_path ||= WebPages.instance.uuid
  end

  def from_cj
    begin
      cj_raw = '{"collection":' + request.body.to_s + '}'
      cj_doc = CollectionJSON.parse(cj_raw)

      if !cj_doc.template.nil? && !cj_doc.template.data.nil?
        rev = WebPages.instance.create_from_collection(create_path, cj_doc)
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
    rev = WebPages.instance.create_from_form(create_path, data)

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
  def title
    "Creative Works Re-used on the Web"
  end

  def collection
    documents.base_uri = base_uri
    documents.error = @error
    documents.to_cj
  end

  def documents
    @documents ||= WebPages.instance.all
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
    documents.count >= 1
  end

  private
  def id
    request.path_info[:id]
  end

  def title
    "Creative Work Re-used on the Web"
  end

  def collection
    documents.base_uri = base_uri
    documents.include_template = false
    documents.to_cj
  end

  def documents
    @documents ||= WebPages.instance.find(id)
  end

end

class RegistrationsResource < CollectionResource
  def allowed_methods
    ["GET", "POST"]
  end

  def base_uri
    @request.base_uri.to_s + 'registrations/'
  end

  def post_is_create?
    true
  end

  def create_path
    @create_path ||= Users.instance.uuid
  end

  def from_cj
    begin
      cj_raw = '{"collection":' + request.body.to_s + '}'
      cj_doc = CollectionJSON.parse(cj_raw)

      if !cj_doc.template.nil? && !cj_doc.template.data.nil?
        rev = Users.instance.create_from_collection(create_path, cj_doc)
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
    rev = Users.instance.create_from_form(create_path, data)

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
  def title
    "Sign up for Project Octopus"
  end

  def collection
    documents.base_uri = base_uri
    documents.error = @error
    documents.to_cj
  end

  def documents
    @documents ||= RegistrationDocuments.new
  end

end

class RegistrationResource < CollectionResource

  def base_uri
    @request.base_uri.to_s + 'registrations/'
  end

  def resource_exists?
    documents.count >= 1
  end

  private
  def identity
    request.path_info[:identity]
  end

  def title
    "Registration Submitted"
  end

  def collection
    documents.base_uri = base_uri
    documents.include_template = false
    documents.include_item_link = false
    documents.to_cj
  end

  def documents
    @documents ||= Users.instance.identify(identity)
  end

end

class UsersResource < CollectionResource
  def allowed_methods
    ["GET"]
  end

  def base_uri
    @request.base_uri.to_s + 'users/'
  end

  def post_is_create?
    true
  end

  def create_path
    @create_path ||= Users.instance.uuid
  end

  private
  def collection
    documents.base_uri = base_uri
    documents.include_template = false
    documents.to_cj
  end

  def documents
    @documents ||= Users.instance.usernames
  end

end

class UserResource < CollectionResource

  def base_uri
    @request.base_uri.to_s + 'users/'
  end

  def resource_exists?
    documents.count >= 1
  end

  private
  def username
    request.path_info[:username]
  end

  def collection
    documents.base_uri = base_uri
    documents.include_template = false
    documents.to_cj
  end

  def documents
    @documents ||= Users.instance.find(username)
  end

end

class AssetsResource < Webmachine::Resource
  def allowed_methods
    ["HEAD", "GET"]
  end

  def content_types_provided
    [["*/*", :to_file]]
  end

  def resource_exists?
    File.expand_path(file_path).start_with?(base_path) and File.file?(file_path)
  end

  def last_modified
    File.mtime(file_path)
  end

  def to_file
    response.headers["Content-Type"] = mime_type
    File.open(file_path, "r")
  end

  private
  def base_path
    File.expand_path("public/assets")
  end

  def file_path
    File.join(base_path, filename)
  end

  def filename
    request.path_info[:filename]
  end

  def mime_type
    @mime_type ||= FileMagic.new(FileMagic::MAGIC_MIME).file(file_path)
  end
end

class FaviconResource < AssetsResource
  def content_types_provided
    [["image/x-icon", :to_file]]
  end

  private
  def base_path
    File.expand_path("public")
  end

  def filename
    "favicon.ico"
  end
end

class ProtectedResource < CollectionResource
  include Webmachine::Resource::Authentication

  def is_authorized?(authorization_header)
    basic_auth(authorization_header, "Project Octopus") do |user, pass|
      user == "admin" && pass == "admin"
      Users.instance.is_authorized?(user, pass)
    end
  end

  private
  def title
    "Thank you for logging in"
  end

end

App = Webmachine::Application.new do |app|
  app.configure do |config|
    config.adapter = :Rack
  end
  app.routes do
    add [], CollectionResource
    add ["favicon.ico"], FaviconResource
    add ["assets", :filename], AssetsResource
    add ["reviews"], ReviewsResource
    add ["reviews", :id], ReviewResource

    add ["registrations"], RegistrationsResource
    add ["registrations", :identity], RegistrationResource
    add ["users"], UsersResource
    add ["users", :username], UserResource
    add ["login"], ProtectedResource

    if configatron.webmachine.trace
      add ['trace', '*'], Webmachine::Trace::TraceResource
    end
  end
end
