require 'singleton'
require 'time'
require 'json'
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

  def create(id, url, name, creator, license, is_based_on_url)
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
    response = server.post(db.path, json)
    JSON.parse(response.body)
  end

  def all
    response = server.get("#{db.path}/_design/all/_view/reviews?descending=true")
    JSON.parse(response.body)
  end

  def find(id)
    uri = URI("#{db.path}/_design/all/_view/webpages")
    params = [["startkey", "\"#{id}\""], ["endkey", "\"#{id}\""]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)
    JSON.parse(response.body)
  end

end
