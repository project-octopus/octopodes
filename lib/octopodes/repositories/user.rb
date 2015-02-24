require 'sequel'
require 'securerandom'
require 'octopodes/domain/user'

include Octopodes::Domain

module Octopodes
  module Repositories
    # Repository to access Users
    class User
      def self.token
        SecureRandom.uuid
      end

      def self.new
        Domain::User.new
      end

      def self.create(token, data)
        pass = data['password']
        username = data['username']
        user_data = { token: token, username: username, password: pass,
                      password_confirmation: pass }
        model = Domain::User.new(user_data)
        model.valid? ? model.save : model
      end

      def self.update(username, token, data)
        model = find(username).first
        if model
          pass = data['password']
          user_data = { token: token, password: pass,
                        password_confirmation: pass }
          model.set(user_data)
          model.valid? ? model.save : model
        end
      end

      def self.list(options = {})
        order = Sequel.lit('username ASC')
        opts = { limit: options[:limit], order: order }
        if options[:startkey]
          startkeys = options[:startkey].split(',')
          _created_at = startkeys.first
          username = startkeys.last
          where = '(username) > (?)', username
          opts[:where] = where
        end
        all(opts)
      end

      def self.find(username)
        Domain::User.where(username: username).all
      end

      def self.identify(token)
        Domain::User.where(token: token).first
      end

      def self.authenticate(username, password)
        user = find(username).first
        user.authenticate(password) if user
      end

      def self.count
        Domain::User.count
      end

      def self.all(options = {})
        limit = options[:limit]
        where = options[:where]
        order = options[:order]
        dataset = Domain::User.where(where).order(order).limit(limit)
        dataset.all
      end

      private_class_method :all
    end
  end
end
