require 'securerandom'

class CouchMigrations

  @server = nil
  @db = nil

  def self.run_on(couch_server, database_path)
    puts "Running migrations"
    @server = couch_server
    @db = database_path

    update_identities_v1
  end

  private

  def self.server
    @server
  end

  def self.db
    @db
  end

  def self.uuid
    uuids['uuids'][0]
  end

  def self.uuids
    response = server.get('/_uuids')
    JSON.parse(response.body)
  end

  def self.make_id(type, id, time = nil)
    version = !time.nil? ? make_version(time) : ''
    prefix = !type.nil? ? type + ":" : ''
    prefix + id + version
  end

  def self.make_version(time)
    v_t = Time.iso8601(time).to_i
    v_r = SecureRandom.hex(2)
    v_s = "::v" + v_t.to_s + '-' + v_r.to_s
  end

  def self.make_token
    uuid
  end

  def self.update_identities_v1
    key = "\"https://w3id.org/identity/v1\""
    context_uri = URI("#{db}/_design/contexts/_view/all")
    params = [["key", key], ["reduce", "false"], ["include_docs", "true"]]
    context_uri.query = URI.encode_www_form(params)
    response = server.get(context_uri.to_s)

    documents = JSON.parse(response.body)

    rows = documents["rows"]
    if rows.size >= 1
      puts "Updating identities to v1"
      docs = rows.map { |row| row["doc"] }
      users = docs.group_by { |doc| doc["@id"] }

      user_context = "contexts/identity/v1"
      doc_type = "Identity"

      users.each do |username, identities|
        latest_id = identities.max_by { |id| id["created"] }
        oldest_id = identities.min_by { |id| id["created"] }

        user_id = "users/#{username}"

        username = latest_id['@id']
        created = oldest_id["created"]
        updated = latest_id["created"]
        doc_id = make_id("identity", username)

        new_id = {
          "_id" => doc_id,
          "@id" => user_id,
          "@context" => user_context,
          "@type" => doc_type,
          "created" => created,
          "updated" => updated,
          "token" => make_token,
          "password" => latest_id["password"]
        }

        new_id_path = db + '/' + doc_id
        resp = server.put(new_id_path, new_id.to_json)

        identities.reject { |i| i["_id"] == latest_id["_id"] }.each_with_index do |id, i|
          alt_doc_id = make_id("identity", username, id["created"])
          alt_id_path = db + '/' + alt_doc_id
          alt_id = {
            "@id" => user_id,
            "@context" => user_context,
            "@type" => doc_type,
            "created" => oldest_id["created"],
            "updated" => id["created"],
            "token" => make_token,
            "password" => id["password"]
          }
          server.put(alt_id_path, alt_id.to_json)
        end

      end

      docs.each do |doc|
        doc_uri = URI(db + '/' + doc['_id'])
        params = [['rev', doc['_rev']]]
        doc_uri.query = URI.encode_www_form(params)
        server.delete(doc_uri.to_s)
      end
    end
  end

end
