require 'net/http'

module Couch
  # Basic library for a raw CouchDB API
  class Server
    def initialize(scheme, host, port, user = nil, password = nil)
      @scheme = scheme
      @host = host
      @port = port
      @user = user
      @password = password
    end

    def delete(uri)
      request(Net::HTTP::Delete.new(uri))
    end

    def get(uri)
      request(Net::HTTP::Get.new(uri))
    end

    def put(uri, json)
      req = Net::HTTP::Put.new(uri)
      req['content-type'] = 'application/json'
      req.body = json
      request(req)
    end

    def post(uri, json)
      req = Net::HTTP::Post.new(uri)
      req['content-type'] = 'application/json'
      req.body = json
      request(req)
    end

    def request(req)
      req.basic_auth(@user, @password) unless @user.nil? || @password.nil?
      Net::HTTP.start(@host, @port, use_ssl: @scheme == 'https') do |http|
        http.request(req)
      end
    end
  end
end
