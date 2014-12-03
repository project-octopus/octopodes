require 'singleton'
require 'time'
require 'json'
require 'collection-json'
require 'bcrypt'
require_relative 'couch'

class Datastore
  include Singleton

  attr_writer :database

  def uuid
    uuids['uuids'][0]
  end

  def uuids
    response = server.get('/_uuids')
    JSON.parse(response.body)
  end

  private
  def db
    @uri ||= URI(@database)
  end

  def password
    !db.password.nil? ? URI::decode(db.password) : nil
  end

  def server
    @server ||= Couch::Server.new(db.scheme, db.host, db.port, db.user, password)
  end

end

class Users < Datastore
  def create(id, data)
    username = data["username"]
    if (find(username).count >= 1)
      {"error" => "conflict", "reason" => "Username `#{username}` is taken."}
    else
      created = Time.now.utc.iso8601
      password = BCrypt::Password.create(data["password"])

      json = {
        "_id" => id,
        "@id" => username,
        "@context" => "https://w3id.org/identity/v1",
        "@type" => "Identity",
        "created" => created,
        "password" => password
      }.to_json
      response = server.post(db.path, json)
      JSON.parse(response.body)
    end
  end

  def create_from_collection(id, collection)
    data = collection.template.data.inject({}) do |hash, cj_data|
      nv = cj_data.to_hash
      hash[nv[:name]] = nv[:value]
      hash
    end

    create(id, data)
  end

  def create_from_form(id, decoded_www_form)
    data = decoded_www_form.inject({}) do |hash, value|
      hash[value.first] = value.last
      hash
    end

    create(id, data)
  end

  def all
    response = server.get("#{db.path}/_design/all/_view/identities")
    JSON.parse(response.body)
    UserDocuments.new(response.body)
  end

  def find(username)
    uri = URI("#{db.path}/_design/all/_view/users")
    params = [["endkey", "[\"#{username}\"]"],
              ["startkey", "[\"#{username}\", {}]"],
              ["limit", "1"], ["descending", "true"]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    UserDocuments.new(response.body)
  end

  def usernames
    uri = URI("#{db.path}/_design/all/_view/usernames?group=true")
    response = server.get(uri.to_s)

    UserDocuments.new(response.body)
  end

  def count
    uri = URI("#{db.path}/_design/all/_view/usernames?group=true")
    response = server.get(uri.to_s)

    docs = JSON.parse(response.body)
    docs["rows"].size
  end

  def identify(identity)
    uri = URI("#{db.path}/_design/all/_view/identities")
    params = [["startkey", "\"#{identity}\""],
              ["endkey", "\"#{identity}\""]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    RegistrationDocuments.new(response.body)
  end

  def is_authorized?(username, password)
    identity = find(username).first

    if !identity.empty?
      user_id = identity["value"]["@id"]
      user_secret = identity["value"]["password"]
      is_authorized = BCrypt::Password.new(user_secret) == password
    else
      # Spend time checking even if the user does not exist
      BCrypt::Password.create((0...16).map { (65 + rand(26)).chr }.join) == password
      is_authorized = false
    end

    is_authorized
  end
end

class WebPages < Datastore

  def create(id, data)
    lastReviewed = Time.now.utc.iso8601

    part = {
      "@type" => "CreativeWork",
      "creator" => data["creator"],
      "license" => data["license"],
      "name" => data["name"],
      "isBasedOnUrl" => data["isBasedOnUrl"]
    }
    part.each { |k,v| part.delete(k) if v.nil? }

    json = {
      "_id" => id,
      "@context" => "http://schema.org",
      "@type" => "WebPage",
      "hasPart" => part,
      "lastReviewed" => lastReviewed,
      "url" => data["url"]
    }.to_json
    response = server.post(db.path, json)
    JSON.parse(response.body)
  end

  def create_from_collection(id, collection)

    data = collection.template.data.inject({}) do |hash, cj_data|
      nv = cj_data.to_hash
      hash[nv[:name]] = nv[:value]
      hash
    end

    create(id, data)
  end

  def create_from_form(id, decoded_www_form)
    data = decoded_www_form.inject({}) do |hash, value|
      hash[value.first] = value.last
      hash
    end

    create(id, data)
  end

 def all
    response = server.get("#{db.path}/_design/all/_view/reviews?descending=true")
    JSON.parse(response.body)
    WebPageDocuments.new(response.body)
  end

  def find(id)
    uri = URI("#{db.path}/_design/all/_view/webpages")
    params = [["startkey", "\"#{id}\""], ["endkey", "\"#{id}\""]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    WebPageDocuments.new(response.body)
  end

  def count
    uri = URI("#{db.path}/_design/all/_view/webpage_count")
    response = server.get(uri.to_s)

    docs = JSON.parse(response.body)
    puts docs["rows"][0]

    !docs["rows"].empty? ? docs["rows"][0]["value"] : 0
  end

end

class Documents

  attr_accessor :error, :base_uri, :include_template, :include_item_link

  def initialize(json = '{}')
    @documents = JSON.parse(json)
    @error = nil
    @base_uri = ''
    @include_template = true
    @include_item_link = true
  end

  def count
    items.size
  end

  def first
    !@documents["rows"].empty? ? @documents["rows"][0] : []
  end

  def to_json
    to_cj.to_json
  end

  def to_cj
    CollectionJSON.generate_for(@base_uri) do |builder|
      builder.set_version("1.0")
      (items || []).each do |i|
        href = @include_item_link ? @base_uri + i[:id] : ''
        builder.add_item(href) do |item|
          (i[:data] || []).each do |d|
            item.add_data d[:name], prompt: d[:prompt], value: d[:value]
          end
          (i[:links] || []).each do |l|
            item.add_link l[:href], l[:rel], prompt: l[:prompt]
          end
        end
      end
      if @include_template
        builder.set_template do |template|
          (template_data || []).each do |datum|
            template.add_data datum[:name], prompt: datum[:prompt]
          end
        end
      end
      unless @error.nil?
        builder.set_error @error
      end
    end
  end

  private
  def items
    []
  end

  def template_data
    []
  end

  def cj_item_datum(hash, key, name, prompt)
    if hash.key?(key)
      {:name => name, :prompt => prompt, :value => hash[key]}
    end
  end

  def cj_item_link(hash, key, rel, prompt)
    if hash.key?(key)
      {:href => hash[key], :rel => rel, :prompt => prompt}
    end
  end
end

class UserDocuments < Documents

  private
  def items
    @items ||= (@documents["rows"] || []).map do |row|
      doc = row["value"]
      item_id = doc["@id"]

      data = [cj_item_datum(doc, "@id", "username", "Username")]
      links = []

      {:id => item_id, :data => data, :links => links}
    end
  end

  def template_data
    [{:name => "password", :prompt => "Password"}]
  end
end

class RegistrationDocuments < Documents
  private
  def items
    @items ||= (@documents["rows"] || []).map do |row|
      doc = row["value"]
      item_id = doc["_id"]

      data = [cj_item_datum(doc, "@id", "username", "Username"),
              cj_item_datum(doc, "created", "created", "Registered"),
              {:name => "message", :prompt => "Message", :value => "Your registration was successful. You may now login."}]
      links = []

      {:id => item_id, :data => data, :links => links}
    end
  end

  def template_data
    [{:name => "username", :prompt => "Username"},
     {:name => "password", :prompt => "Password"}]
  end
end

class WebPageDocuments < Documents

  private
  def items
    @items ||= (@documents["rows"] || []).map do |row|
      doc = row["value"]
      item_id = doc["_id"]
      part = doc.key?("hasPart") ? doc["hasPart"] : []

      data = [cj_item_datum(part, "name", "name", "Title"),
              cj_item_datum(part, "creator", "creator", "Creator"),
              cj_item_datum(part, "license", "license", "License"),
              cj_item_datum(doc, "lastReviewed", "date", "Date")]
      data.reject!(&:nil?)

      links = [cj_item_link(doc, "url", "full", "Web Page URL"),
               cj_item_link(part, "isBasedOnUrl", "isBasedOnUrl", "Original URL")]
      links.reject!(&:nil?)

      {:id => item_id, :data => data, :links => links}
    end
  end

  def template_data
    [{:name => "url", :prompt => "Web Page URL"},
     {:name => "name", :prompt => "Title"},
     {:name => "creator", :prompt => "Creator"},
     {:name => "license", :prompt => "License"},
     {:name => "isBasedOnUrl", :prompt => "Based on URL"}]
  end

end
