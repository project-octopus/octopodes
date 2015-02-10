require 'erb'

module Octopodes
  module Views
    class Application
      include ERB::Util

      def initialize
        @layout = File.read(File.expand_path('lib/octopodes/templates/application.html.erb'))
        @content = File.read(File.expand_path('lib/octopodes/templates/blank.html.erb'))
      end

      def partial(content)
        t = ERB.new(content)
        t.result(binding)
      end

      def render
        ERB.new(@layout).result(binding)
      end
    end

    class Collection < Application
      attr_accessor :href

      def initialize(collection, title, menu, body = nil)
        @title = title
        @body = body
        @menu = menu
        @href = collection.href

        links = (collection.links || []).partition do |l|
          l.rel != 'previous' && l.rel != 'next'
        end

        @links = links[0]
        @pagination = links[1]

        @items = collection.items
        @error = collection.error
        @queries = collection.queries
        @inputs = collection.template.data unless collection.template.nil?
        @layout = File.read(File.expand_path('lib/octopodes/templates/application.html.erb'))
        @content = File.read(File.expand_path('lib/octopodes/templates/collection.html.erb'))
      end

      def abridge(url, max = 10)
        self.class.abridge url, max
      end

      def truncate(url, max)
        self.class.truncate url, max
      end

      def self.abridge(url, max = 10)
        if url =~ /\A#{URI.regexp}\z/
          begin
            uri = URI(url)
            abridged = uri.host unless uri.host.nil?
          rescue URI::InvalidURIError
            abridged = nil
          end
        end

        if abridged.nil?
          truncate(url, max)
        else
          abridged
        end
      end

      def self.truncate(url, max_url_length = 60)
        protocol_length = 8 # http:// or https://
        url_too_long = url.length - protocol_length > max_url_length

        if url =~ /\A#{URI.regexp}\z/
          begin
            uri = URI(url)
            host = !uri.host.nil? ? uri.host : ''
            path = !uri.path.nil? ? uri.path : ''
            query = !uri.query.nil? ? "?#{uri.query}" : ''
            if url_too_long
              max = max_url_length
              h_len = host.length
              path_limit = max > h_len ? max - h_len : 0
              host + (path + query)[0..path_limit] + '...'
            else
              host + path + query
            end
          rescue URI::InvalidURIError
            url[0..max_url_length]
          end
        else
          if url_too_long
            url[0..max_url_length - 3] + '...'
          else
            url
          end
        end
      end
    end

    class Pages < Application
      def initialize(page, title, menu)
        @title = title
        @menu = menu
        @layout = File.read(File.expand_path('lib/octopodes/templates/application.html.erb'))
        @content = File.read(File.expand_path("lib/octopodes/templates/#{page}.html.erb"))
      end
    end
  end
end
