require 'time'
require 'json'
require 'rss'
require 'collection-json'
require 'bcrypt'

require_relative 'couch'
require_relative 'models'

class Datastore

  @database = nil
  @server = nil
  @uri = nil

  def self.connect(database)
    @uri = nil
    @server = nil
    @database = database
  end

  def self.uuid
    uuids['uuids'][0]
  end

  def self.uuids
    response = server.get('/_uuids')
    JSON.parse(response.body)
  end

  private
  def self.db
    @uri ||= URI(@database)
  end

  def self.password
    !db.password.nil? ? URI::decode(db.password) : nil
  end

  def self.server
    @server ||= Couch::Server.new(db.scheme, db.host, db.port, db.user, password)
  end

  def self.trans_form_data(decoded_www_form)
    decoded_www_form.inject({}) do |hash, value|
      hash[value.first] = value.last
      hash
    end
  end

  def self.extract_data(hash, keys)
    hash.select {|k,v| keys.include?(k) && !v.nil? && !v.empty?}
  end

  def self.save_model(model)
    if model.valid?
      response = server.post(db.path, model.to_json)
      JSON.parse(response.body)
    else
      {"error" => "forbidden", "reason" => model.errors.full_messages.join(", ")}
    end
  end

end

class Users < Datastore
  def self.create(id, data)
    username = data["username"]
    if (find(username).count >= 1)
      {"error" => "conflict", "reason" => "Username `#{username}` is taken."}
    else
      save(id, username, data)
    end
  end

  def self.save(id, username, data)

    user = Identity.new.tap do |i|
      i.doc_id = id
      i.username = username
      i.new_password = data['password']
    end

    save_model(user)
  end

  def self.create_from_collection(id, collection)
    data = collection.template.data.inject({}) do |hash, cj_data|
      nv = cj_data.to_hash
      hash[nv[:name]] = nv[:value]
      hash
    end

    create(id, data)
  end

  def self.create_from_form(id, decoded_www_form)
    data = trans_form_data(decoded_www_form)

    create(id, data)
  end

  def self.save_from_form(id, username, decoded_www_form)
    data = trans_form_data(decoded_www_form)

    save(id, username, data)
  end

  def self.all
    response = server.get("#{db.path}/_design/all/_view/identities")
    JSON.parse(response.body)
    UserDocuments.new(response.body)
  end

  def self.find(username)
    uri = URI("#{db.path}/_design/all/_view/users")
    params = [["endkey", "[\"#{username}\"]"],
              ["startkey", "[\"#{username}\", {}]"],
              ["limit", "1"], ["descending", "true"]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    UserDocuments.new(response.body)
  end

  def self.usernames(limit = nil, startkey = nil, prevkey = nil)
    uri = URI("#{db.path}/_design/all/_view/usernames")
    params  = [["group", "true"]]

    if startkey
      params << ["startkey", startkey]
    end

    if limit
      params << ["limit", limit + 1]
    end

    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)
    UserDocuments.new(response.body, limit, startkey, prevkey)
  end

  def self.count
    uri = URI("#{db.path}/_design/all/_view/usernames?group=true")
    response = server.get(uri.to_s)

    docs = JSON.parse(response.body)
    docs["rows"].size
  end

  def self.identify(identity)
    uri = URI("#{db.path}/_design/all/_view/identities")
    params = [["startkey", "\"#{identity}\""],
              ["endkey", "\"#{identity}\""]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    SignupDocuments.new(response.body)
  end

  def self.check_auth(username, password)
    identity = find(username).first
    user = {}

    if !identity.empty?
      user_id = identity["value"]["@id"]
      user_secret = identity["value"]["password"]
      is_authorized = BCrypt::Password.new(user_secret) == password
      if is_authorized
        user = {:username => user_id}
      end
    else
      # Spend time checking even if the user does not exist
      BCrypt::Password.create((0...16).map { (65 + rand(26)).chr }.join) == password
    end

    user
  end

end

class WebPages < Datastore

  def self.create(id, data, username)
    webpage_keys = ["description", "url"]
    work_keys = ["creator", "isBasedOnUrl", "name", "license"]
    media_keys = ["contentUrl"]

    webpage_data = extract_data(data, webpage_keys)
    work_data = extract_data(data,work_keys)
    media_data = extract_data(data,media_keys)

    webpage = WebPage.new(webpage_data).tap do |w|
      w.doc_id = id

      w.reviewedBy = Person.new.tap do |p|
        p.id = username
        p.context = nil
      end

      w.work = CreativeWork.new(work_data).tap do |c|
        c.context = nil
        if !media_data.empty?
          c.media = MediaObject.new(media_data) do |a|
            a.context = nil
          end
        end
      end
    end

    save_model(webpage)
  end

  def self.create_from_collection(id, collection, username)

    data = collection.template.data.inject({}) do |hash, cj_data|
      nv = cj_data.to_hash
      hash[nv[:name]] = nv[:value]
      hash
    end

    create(id, data, username)
  end

  def self.create_from_form(id, decoded_www_form, username)
    data = trans_form_data(decoded_www_form)

    create(id, data, username)
  end

  def self.all(limit = nil, startkey = nil, prevkey = nil)
    uri = URI("#{db.path}/_design/all/_view/reviews")
    params  = [["descending", "true"]]

    if startkey
      params << ["startkey", startkey]
    end

    if limit
      params << ["limit", limit + 1]
    end

    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)
    JSON.parse(response.body)
    WebPageDocuments.new(response.body, limit, startkey, prevkey)
  end

  def self.find(id)
    uri = URI("#{db.path}/_design/all/_view/webpages")
    params = [["startkey", "\"#{id}\""], ["endkey", "\"#{id}\""]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    WebPageDocuments.new(response.body)
  end

  def self.count
    uri = URI("#{db.path}/_design/all/_view/webpage_count")
    response = server.get(uri.to_s)

    docs = JSON.parse(response.body)

    !docs["rows"].empty? ? docs["rows"][0]["value"] : 0
  end

  def self.empty_or_valid_url?(url)
    url.nil? || url.empty? || url =~ /\A#{URI::regexp}\z/
  end

end

class Documents

  attr_accessor :data, :error, :base_uri, :links, :include_template,
                :include_queries, :include_items, :include_item_link,
                :queries

  def initialize(json = '{}', limit = nil, startkey = nil, prevkey = nil)
    @limit = limit
    @startkey = startkey
    @prevkey = prevkey
    @next_startkey = nil
    @error = nil
    @base_uri = ''
    @links = []
    @include_template = true
    @include_items = true
    @include_item_link = true
    @data = {}

    @documents = JSON.parse(json)
    rows = @documents["rows"]
    if limit && !rows.nil? && !rows.empty?
      if rows.size > limit
        last = rows.pop
        key = last["key"]
        if key.kind_of?(Array)
          @next_startkey =  "[" + last["key"].map{ |i| '"' + i + '"' }.join(",") + "]"
        else
          @next_startkey =  '"' + key + '"'
        end
      end
    end
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
      (links || []).each do |l|
        builder.add_link l[:href], l[:rel], prompt: l[:prompt]
      end
      (items || []).each do |i|
        href = @include_item_link ? @base_uri + i[:id] : ''
        if @include_items
          builder.add_item(href) do |item|
            (i[:data] || []).each do |d|
              item.add_data d[:name], prompt: d[:prompt], value: d[:value]
            end
            (i[:links] || []).each do |l|
              item.add_link l[:href], l[:rel], prompt: l[:prompt]
            end
          end
        end
      end
      if @include_queries
        builder.add_query(@base_url, "search", prompt: "Search") do |query|
          (query_data || []).each do |datum|
            query.add_data datum[:name], prompt: datum[:prompt],
                                         value: datum[:value]
          end
        end
      end
      if @include_template
        builder.set_template do |template|
          (template_data || []).each do |datum|
            template.add_data datum[:name], prompt: datum[:prompt], value: datum[:value]
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

  def links
    if @startkey
      start_key = URI(@base_uri)
      start_key.query = URI.encode_www_form([["startkey", @prevkey]])
      @links << {:href => start_key, :rel => "previous", :prompt => "Previous"}
    end

    if @next_startkey
      next_key = URI(@base_uri)
      next_params = [["startkey", @next_startkey],
                     ["prevkey", @startkey]]
      next_key.query = URI.encode_www_form(next_params)
      @links << {:href => next_key, :rel => "next", :prompt => "Next"}
    end

    @links
  end

  def cj_item_datum(hash, key, name, prompt)
    if hash.key?(key) && !hash[key].nil? && !hash[key].empty?
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

class SignupDocuments < Documents
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
    data = !@data.nil? ? @data : {}
    [{:name => "username", :prompt => "Username", :value => data["username"]},
     {:name => "password", :prompt => "Password"}]
  end
end

class WebPageDocuments < Documents

  def to_atom
    RSS::Maker.make("atom") do |maker|
      maker.channel.author = "Project Octopus"
      maker.channel.updated = Time.now.to_s
      maker.channel.about = "Project Octopus Feed"
      maker.channel.title = "Project Octopus"

      (@documents["rows"] || []).each do |row|
        doc = row["value"]
        item_id = doc["_id"]
        part = doc.key?("hasPart") ? doc["hasPart"] : {}

        name = part.key?("name") ? part["name"] : "something"
        creator = part.key?("creator") ? part["creator"] : "a creator"
        webpage_url = doc["url"]

        if webpage_url =~ /\A#{URI::regexp}\z/
          webpage_host = URI(webpage_url).host
        else
          webpage_host = webpage_url[0..15] + '...'
        end

        original_url = part.key?("isBasedOnUrl") ? part["isBasedOnUrl"] : ""

        title = "#{webpage_host} uses #{name} by #{creator}"
        summary = "#{webpage_url} uses #{name} by #{creator} #{original_url}"

        maker.items.new_item do |item|
          item.link = @base_uri + item_id
          item.title = title
          item.description = summary
          item.updated = doc["lastReviewed"]
        end
      end
    end
  end

  private
  def items
    @items ||= (@documents["rows"] || []).map do |row|
      doc = row["value"]
      item_id = doc["_id"]
      part = doc.key?("hasPart") ? doc["hasPart"] : {}
      media = part.key?("associatedMedia") ? part["associatedMedia"] : {}
      reviewedBy = doc.key?("reviewedBy") ? doc["reviewedBy"] : {}

      data = [cj_item_datum(part, "name", "name", "Title"),
              cj_item_datum(part, "creator", "creator", "Creator"),
              cj_item_datum(part, "license", "license", "License"),
              cj_item_datum(reviewedBy, "@id", "reviewedBy", "Reviewed By"),
              cj_item_datum(doc, "description", "description", "Description"),
              cj_item_datum(doc, "lastReviewed", "date", "Date")]

      links = []
      if doc.key?("url")
        if doc["url"] =~ /\A#{URI::regexp}\z/
          links << cj_item_link(doc, "url", "full", "Web Page URL")
        else
          data << cj_item_datum(doc, "url", "url", "Web Page")
        end
      end
      if part.key?("isBasedOnUrl")
        if part["isBasedOnUrl"] =~ /\A#{URI::regexp}\z/
          links << cj_item_link(part, "isBasedOnUrl", "isBasedOnUrl", "Original URL")
        else
          data << cj_item_datum(part, "isBasedOnUrl", "isBasedOnUrl", "Original")
        end
      end
      if media.key?("contentUrl")
        if media["contentUrl"] =~ /\A#{URI::regexp}\z/
          links << cj_item_link(media, "contentUrl", "contentUrl", "Media File URL")
        else
          data << cj_item_datum(media, "contentUrl", "contentUrl", "Media File URL")
        end
      end

      data.reject!(&:nil?)

      {:id => item_id, :data => data, :links => links}
    end
  end

  def template_data
    data = !@data.nil? ? @data : {}
    [{:name => "url", :prompt => "Web Page URL", :value => data["url"]},
     {:name => "name", :prompt => "Title"},
     {:name => "contentUrl", :prompt => "Media File URL"},
     {:name => "creator", :prompt => "Creator"},
     {:name => "license", :prompt => "License"},
     {:name => "description", :prompt => "Description"},
     {:name => "isBasedOnUrl", :prompt => "Based on URL"}]
  end

  def query_data
    queries = !@queries.nil? ? @queries : {}
    [{:name => "limit", :prompt => "Limit", :value => queries["limit"]}]
  end

end
