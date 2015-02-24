require 'sequel'
require 'securerandom'
require 'octopodes/domain/thing'
require 'octopodes/domain/user'

module Octopodes
  module Repositories
    # Repository to access Things
    class Thing
      def self.domain
        Domain::Thing
      end

      def self.uuid
        SecureRandom.uuid
      end

      def self.new(data = {})
        domain.new(data)
      end

      # Create a model or return it unsaved with errors
      def self.create(uuid, data = {}, user = nil)
        model = domain.new(data)
        model.uuid = uuid
        model.updated_by = user if user.is_a?(Domain::User)
        model.valid? ? model.save : model
      end

      # Update a model or return it unsaved with errors
      def self.update(uuid, data = {}, user = nil)
        model = find(uuid).first
        if model
          model.set(data)
          model.updated_by = user if user.is_a?(Domain::User)
          model.valid? ? model.save : model
        end
      end

      def self.find(uuid)
        domain.where(uuid: uuid).all
      end

      # A Thing does not have parts, so just find it alone.
      def self.find_with_parts(uuid)
        find(uuid)
      end

      def self.update_provenance(uuid, _data = {}, _user = nil)
        find(uuid).first
      end

      def self.history(_uuid)
      end

      # TODO: co-ordinate pagination strategy with Collection Presenter
      def self.recent(options = {})
        order = Sequel.lit('created_at DESC, uuid DESC')
        opts = { limit: options[:limit], order: order }
        if options[:startkey]
          startkeys = options[:startkey].split(',')
          created_at = startkeys.first
          uuid = startkeys.last
          where = '(created_at, uuid) < (?, ?)', created_at, uuid
          opts[:where] = where
        end
        all(opts)
      end

      def self.count
        domain.count
      end

      # Returns all Things, regardless of type
      def self.all(options = {})
        limit = options[:limit]
        where = options[:where]
        order = options[:order]
        dataset = domain.where(where).order(order).limit(limit)
        dataset.all
      end

      private_class_method :all
    end
  end
end
