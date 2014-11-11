require 'net/http'

module Couch

  class Server
    def initialize(host, port, username = nil, password = nil)
      @host = host
      @port = port
      @username = username
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
      req["content-type"] = "application/json"
      req.body = json
      request(req)
    end

    def post(uri, json)
      req = Net::HTTP::Post.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req)
    end

    def request(req)
      unless @username.nil? or @password.nil?
        req.basic_auth(@username, @password)
      end
      Net::HTTP.start(@host, @port) { |http|http.request(req) }
    end

    private

    def handle_error(req, res)
      e = RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}")
      raise e
    end
  end

end
