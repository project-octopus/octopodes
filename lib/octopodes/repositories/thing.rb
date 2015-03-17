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

      def self.find_by_hostname(hostname, options = {})
        match_hostname = 'substring(url '\
                         "from substring(url from '.*://([^/]*)' )) = ?",
                         hostname
        order = Sequel.lit('created_at DESC, uuid DESC')
        limit = options[:limit]

        if options[:startkey]
          startkeys = options[:startkey].split(',')
          created_at = startkeys.first
          uuid = startkeys.last
          match_startkey = '(created_at, uuid) < (?, ?)', created_at, uuid
          match = domain.where(match_hostname).where(match_startkey)
        else
          match = domain.where(match_hostname)
        end

        dataset = match.order(order).limit(limit)
        dataset.all
      end

      def self.count_by_hostname(hostname)
        match_hostname = 'substring(url '\
                         "from substring(url from '.*://([^/]*)' )) = ?",
                         hostname
        domain.where(match_hostname).count
      end

      def self.history(_uuid)
      end

      def self.recent(options = {})
        recent_dataset(options).all
      end

      def self.count
        domain.count
      end

      def self.search(text, options = {})
        if !text.nil? && !text.empty?
          search_dataset(text, options).all
        else
          []
        end
      end

      def self.search_count(text)
        if !text.nil? && !text.empty?
          search_dataset(text).count
        else
          0
        end
      end

      # TODO: co-ordinate pagination strategy with Collection Presenter
      def self.recent_dataset(options = {})
        order = Sequel.lit('created_at DESC, uuid DESC')
        opts = { limit: options[:limit], order: order }
        if options[:startkey]
          startkeys = options[:startkey].split(',')
          created_at = startkeys.first
          uuid = startkeys.last
          where = '(created_at, uuid) < (?, ?)', created_at, uuid
          opts[:where] = where
        end
        all_dataset(opts)
      end

      def self.search_dataset(text, options = {})
        w_name = Sequel.ilike(:name, "%#{text}%")
        w_url = Sequel.ilike(:url, "%#{text}%")
        w_desc = Sequel.ilike(:description, "%#{text}%")
        w_lic = Sequel.ilike(:license, "%#{text}%")
        recent_dataset(options).where(w_name | w_url | w_desc | w_lic)
      end

      def self.all_dataset(options = {})
        limit = options[:limit]
        where = options[:where]
        order = options[:order]
        domain.where(where).order(order).limit(limit)
      end

      private_class_method :all_dataset, :search_dataset, :recent_dataset
    end
  end
end
