require 'singleton'
require 'time'
require 'json'
require_relative 'couch'

class Database
  include Singleton

  attr_writer :host, :port, :username, :password

  def server
    @server ||= Couch::Server.new(host, port)
  end

  def uuid
    uuids['uuids'][0]
  end

  def uuids
    response = server.get('/_uuids')
    JSON.parse(response.body)
  end

  private
  def host
    @host || 'localhost'
  end

  def port
    @port || '5984'
  end

end

class Reviews
  include Singleton

  attr_writer :database

  def create(id, url, name, creator, license, is_based_on_url)
    uri = "/#{@database}"
    lastReviewed = Time.now.utc.iso8601

    part = {"@type" => "CreativeWork"}
    unless creator.to_s.empty? then part["creator"] = creator end
    unless license.to_s.empty? then part["license"] = license end
    unless name.to_s.empty? then part["name"] = name end
    unless is_based_on_url.to_s.empty? then part["isBasedOnUrl"] = is_based_on_url end

    json = {
      "_id" => id,
      "@context" => "http://schema.org",
      "@type" => "WebPage",
      "hasPart" => part,
      "lastReviewed" => lastReviewed,
      "url" => url
    }.to_json
    response = server.post(uri, json)
    JSON.parse(response.body)
  end

  def all
    response = server.get("/#{@database}/_design/all/_view/reviews?descending=true")
    JSON.parse(response.body)
  end

  def find(id)
    uri = URI("/#{@database}/_design/all/_view/webpages")
    params = [["startkey", "\"#{id}\""], ["endkey", "\"#{id}\""]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)
    JSON.parse(response.body)
  end

  private
  def server
    Database.instance.server
  end

end
