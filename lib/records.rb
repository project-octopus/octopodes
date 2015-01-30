require 'time'
require 'json'
require 'rss'
require 'collection-json'
require 'bcrypt'

require_relative 'couch'
require_relative 'models'

class Datastore

  @@database = nil
  @@server = nil
  @@uri = nil

  def self.connect(database)
    @@uri = nil
    @@server = nil
    @@database = database
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
    @@uri ||= URI(@@database)
  end

  def self.password
    !db.password.nil? ? URI::decode(db.password) : nil
  end

  def self.server
    @@server ||= Couch::Server.new(db.scheme, db.host, db.port, db.user, password)
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

  def self.design_uri(paths, params)
    design = paths[:design]
    view = paths[:view]
    uri = URI("#{db.path}/_design/#{design}/_view/#{view}")
    uri.query = URI.encode_www_form(params)
    uri
  end

  def self.fetch_and_parse(uri)
    response = server.get(uri.to_s)
    JSON.parse(response.body)
  end

  def self.fetch_recordset(uri)
    RecordSet.new(fetch_and_parse(uri))
  end

end

class Users < Datastore
  def self.token
    uuid
  end

  def self.create(token, data)
    username = data["username"]
    if (exists(username))
      {"error" => "conflict", "reason" => "Username `#{username}` is taken."}
    else
        user = Identity.new.tap do |i|
          i.username = username
          i.new_password = data['password']
          i.token = token
        end

        save_model(user)
    end
  end

  def self.update(token, username, data)
    first_user_doc = find(username).first

    if !first_user_doc.empty?
      current = Identity.new(first_user_doc["doc"])
      current.version!
      save_model(current)

      new = Identity.new(first_user_doc["doc"])
      new.new_password = data["password"]
      new.update!
      save_model(new)
    end
  end

  def self.create_from_collection(token, collection)
    data = collection.template.data.inject({}) do |hash, cj_data|
      nv = cj_data.to_hash
      hash[nv[:name]] = nv[:value]
      hash
    end

    create(token, data)
  end

  def self.create_from_form(token, decoded_www_form)
    data = trans_form_data(decoded_www_form)

    create(token, data)
  end

  def self.update_from_form(token, username, decoded_www_form)
    data = trans_form_data(decoded_www_form)

    update(token, username, data)
  end

  def self.exists(username)
    uri = URI("#{db.path}/_design/all/_view/usernames")
    params = [["key", "\"#{username}\""], ["reduce", "false"]]

    uri.query = URI.encode_www_form(params)
    response = server.get(uri.to_s)

    docs = JSON.parse(response.body)
    docs["rows"].size >= 1
  end

  def self.find(username)
    uri = URI("#{db.path}/_design/all/_view/users")

    user = Identity.new.tap do |i|
      i.username = username
    end

    params = [["endkey", "[\"#{user.id}\"]"],
              ["startkey", "[\"#{user.id}\", {}]"],
              ["reduce", "false"], ["descending", "true"],
              ["include_docs", "true"]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    UserDocuments.new(response.body)
  end

  def self.usernames(limit = nil, startkey = nil, prevkey = nil)
    uri = URI("#{db.path}/_design/all/_view/usernames")
    params  = [["reduce", "false"], ["include_docs", "true"]]

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
    uri = URI("#{db.path}/_design/all/_view/usernames")
    response = server.get(uri.to_s)

    docs = JSON.parse(response.body)
    docs["rows"][0]["value"]
  end

  def self.identify(token)
    uri = URI("#{db.path}/_design/all/_view/user_tokens")
    params = [["key", "\"#{token}\""], ["reduce", "false"], ["limit", "1"],
              ["include_docs", "true"]]
    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    SignupDocuments.new(response.body)
  end

  def self.check_auth(username, password)
    user = {}

    if (!username.nil? && !password.nil?)
      first_user_doc = find(username).first

      if !first_user_doc.empty?
        identity = Identity.new(first_user_doc["doc"])
        is_authorized = identity.password_match?(password)
        if is_authorized
          user = {:username => identity.username}
        end
      end
    end

    user
  end

end

class RecordSet
  attr_accessor :error

  def initialize(documents = {})
    @documents = documents
    @items = process(documents)
  end

  def count
    @items.size
  end

  def items
    @items
  end

  def pop
    @items.pop
  end

  def add(item)
    @items << item
  end

  def last_key
    if(count >= 1)
      @documents["rows"].last["key"]
    end
  end

  def status=(response)
    if(response.key?("error"))
      @error = {"title" => response["error"], "message" => response["reason"]}
    end
  end

  private
  def process(documents)
    (documents["rows"] || []).map do |row|
      coerce_doc(row["doc"])
    end
  end

  def coerce_doc(doc)
    case doc["@type"]
    when "CreativeWork" then CreativeWork.new(doc)
    when "ItemPage" then ItemPage.new(doc)
    else Schema.new(doc)
    end
  end
end

class CreativeWorks < Datastore

  def self.new
    RecordSet.new.tap { |r| r.add(self.model.new) }
  end

  def self.create(id, data = {}, username)
    save_and_make_recordset(id, data, username)
  end

  def self.update(id, edit, data = {}, username)
    save_and_make_recordset(id, data, username)
  end

  def self.all(options = {})
    params  = [[:reduce, "false"], [:include_docs, "true"]]

    if options[:startkey]
      params << ["startkey", options[:startkey]]
    end

    if options[:limit]
      params << ["limit", options[:limit] + 1]
    end

    uri = design_uri({:design => "all", :view => self.design_doc(:all)}, params)
    fetch_recordset(uri)
  end

  def self.find(id)
    key = self.model::id_prefix + id
    params  = [[:reduce, "false"], [:include_docs, "true"],
               ["startkey", "[\"#{key}\"]"],["endkey", "[\"#{key}\", {}]"]]
    uri = design_uri({:design => "all", :view => self.design_doc(:find)}, params)
    fetch_recordset(uri)
  end

  def self.history(id)
    key = self.model::id_prefix + id
    params  = [[:reduce, "false"], [:include_docs, "true"],
               ["endkey", "[\"#{key}\"]"],["startkey", "[\"#{key}\", {}]"],
               ["descending", "true"]]
    uri = design_uri({:design => "all", :view => self.design_doc(:history)}, params)
    fetch_recordset(uri)
  end

  private
  def self.model
    CreativeWork
  end

  def self.design_doc(doc)
    case doc
    when :all then 'works'
    when :find then 'works_with_publications'
    when :history then 'work_history'
    end
  end

  def self.save_and_make_recordset(id, data = {}, username)
    work = make_work(id, data, username)
    status = validate_and_save(work)
    RecordSet.new.tap do |r|
      r.add(work)
      r.status = status
    end
  end

  def self.make_work(id, data = {}, username)
    safe_data = self.model::whitelist(data)
    existing_work = find(id).items.first

    unless existing_work.nil?
      work = existing_work.merge(safe_data)
      work.update!
    else
      work = self.model.new(safe_data)
      work.slug = id
    end

    work.tap { |w| w['reviewedBy'] = "users/" + username }
  end

  def self.save(creative_work)
    response = server.post(db.path, creative_work.to_json)
    JSON.parse(response.body)
  end

  def self.validate_and_save(creative_work)
    if creative_work.valid?
      try_to_version(creative_work)
      save(creative_work)
    else
      formulate_validation_error(creative_work)
    end
  end

  def self.try_to_version(creative_work)
    existing_work = find(creative_work.slug).items.first

    unless existing_work.nil?
      version_and_save(existing_work)
    end
  end

  def self.version_and_save(creative_work)
    creative_work.version!
    save(creative_work)
  end

  def self.formulate_validation_error(creative_work)
    {"error" => "Invalid Input",
     "reason" => creative_work.errors.full_messages.join(", ")}
  end
end

class ItemPages < CreativeWorks
  private
  def self.model
    ItemPage
  end

  def self.design_doc(doc)
    case doc
    when :find then 'itempages'
    when :history then 'itempages_history'
    end
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
      w.name = "Untitled"

      w.reviewedBy = Person.new.tap do |p|
        p.id = username
        p.context = nil
      end

      w.work = CreativeWork.new(work_data).tap do |c|
        c.context = nil
        c.name = "Untitled" if work_data["name"].nil?
        if !media_data.empty?
          c.media = MediaObject.new(media_data) do |a|
            a.name = "Untitled"
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

  def self.by_url(limit, url)

    uri = URI("#{db.path}/_design/all/_view/urls")
    params  = []

    params << ["key", '"' + url + '"']
    params << ["limit", limit]

    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)
    JSON.parse(response.body)
    WebPageDocuments.new(response.body, limit)
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

  def self.domains
    uri = URI("#{db.path}/_design/all/_view/domains?group=true&group_level=1")
    response = server.get(uri.to_s)

    DomainDocuments.new(response.body)
  end

  def self.by_domain(domain, limit = nil, startkey = nil, prevkey = nil)
    endkey = "[\"#{domain}\", {}]"
    uri = URI("#{db.path}/_design/all/_view/domains")
    params = [["reduce", "false"], ["endkey", endkey], ["include_docs", "true"]]

    if startkey.nil?
      params << ["startkey", "[\"#{domain}\"]"]
    else
      params << ["startkey", startkey]
    end

    if limit
      params << ["limit", limit + 1]
    end

    uri.query = URI.encode_www_form(params)

    response = server.get(uri.to_s)

    WebPageDocuments.new(response.body, limit, startkey, prevkey, true)
  end

end

class Documents

  attr_accessor :data, :error, :base_uri, :links, :include_template,
                :include_queries, :include_items, :include_item_link,
                :queries

  def initialize(json = '{}', limit = nil, startkey = nil, prevkey = nil, include_docs = false)
    @limit = limit
    @startkey = startkey
    @prevkey = prevkey
    @next_startkey = nil
    @include_docs = include_docs
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
      start_key.query = URI.encode_www_form([["startkey", @prevkey], ["limit", @limit]])
      @links << {:href => start_key, :rel => "previous", :prompt => "Previous"}
    end

    if @next_startkey
      next_key = URI(@base_uri)
      next_params = [["startkey", @next_startkey],
                     ["prevkey", @startkey],
                     ["limit", @limit]]
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
      doc = row["doc"]
      identity = Identity.new(doc)
      username = identity.username
      created = identity[:created]

      data = [{:name => "username", :prompt => "Username", :value => username},
              {:name => "dateCreated", :prompt => "Member since", :value => created}]
      links = []

      {:id => identity.username, :data => data, :links => links}
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
      doc = row["doc"]
      item_id = doc["_id"]

      data = [{:name => "message", :prompt => "Message", :value => "Your registration was successful. You may now login."}]
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
        doc = @include_docs ? row["doc"] : row["value"]
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
      doc = @include_docs ? row["doc"] : row["value"]
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
    [{:name => "url", :prompt => "URL", :value => queries["url"]},
     {:name => "limit", :prompt => "Limit", :value => queries["limit"]}]
  end

end

class DomainDocuments < Documents

  private
  def items
    @items ||= (@documents["rows"] || []).map do |row|
      domain = row["key"].first
      count = row["value"]
      data = [{:name => "domain", :prompt => "Domain", :value => domain},
              {:name => "count", :prompt => "Records", :value => count}]
      {:id => domain, :data => data, :links => []}
    end
  end

end

class RecordCollection

  def initialize(recordset, options = {})
    @recordset = recordset

    params = {
      :base_uri => '',
      :error => @recordset.error,
      :include_items => true,
      :include_item_link => true,
      :include_template => false,
      :links => [],
      :limit => nil,
      :startkey => nil,
      :prevkey => nil
    }.merge(options)

    params.each do |key,value|
      self.instance_variable_set("@#{key}".to_sym, value)
    end

    if @limit && @recordset.count > @limit
      last_key = @recordset.last_key

      if last_key.kind_of?(Array)
        @next_startkey = last_key.to_s
      else
        @next_startkey = '"' + last_key + '"'
      end

      @recordset.pop
    end

    if @startkey
      start_key = URI(@base_uri)
      start_key.query = URI.encode_www_form([["startkey", @prevkey], ["limit", @limit]])
      @links << {:href => start_key, :rel => "previous", :prompt => "Previous"}
    end

    if @next_startkey
      next_key = URI(@base_uri)
      next_params = [["startkey", @next_startkey],
                     ["prevkey", @startkey],
                     ["limit", @limit]]
      next_key.query = URI.encode_www_form(next_params)
      @links << {:href => next_key, :rel => "next", :prompt => "Next"}
    end
  end

  def to_json
    to_cj.to_json
  end

  def to_cj
    CollectionJSON.generate_for(@base_uri) do |builder|
      builder.set_version("1.0")
      add_links_to builder, @links
      add_items_to builder if @include_items
      add_template_to builder if @include_template
      builder.set_error @error unless @error.nil?
    end
  end

  private
  def add_links_to(item, links)
    (links || []).each do |l|
      item.add_link l[:href], l[:rel], prompt: l[:prompt]
    end
  end

  def add_items_to(builder)
    @recordset.items.each do |record|
      builder.add_item(build_item_href(record)) do |item|
        add_data_to item, record.items
        add_links_to item, record.links
      end
    end
  end

  def add_template_to(builder)
    builder.set_template do |template|
      add_data_to template, @recordset.items.first.template
    end
  end

  def build_item_href(record)
    href = @include_item_link ? record.href : ''
  end

  def add_data_to(item, data)
    data.each do |datum|
      item.add_data datum.first, datum.last
    end
  end
end
