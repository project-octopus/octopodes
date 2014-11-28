require 'singleton'
require 'time'
require 'json'
require 'collection-json'
require_relative 'couch'

class Documents
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

class WebPages < Documents

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

end

class WebPageDocuments

  attr_accessor :error, :base_uri, :include_template

  def initialize(json)
    @documents = JSON.parse(json)
    @error = nil
    @base_uri = ''
    @include_template = true
  end

  def count
    items.size
  end

  def to_json
    to_cj.to_json
  end

  def to_cj
    CollectionJSON.generate_for(@base_uri) do |builder|
      builder.set_version("1.0")
      (items || []).each do |i|
        href = @base_uri + i[:id]
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
