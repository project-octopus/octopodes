require 'hashie'
require 'active_model'
require 'bcrypt'
require 'securerandom'

require 'hashie/thrash'

module Octopodes
  module Models
    # Class that models a JSON-LD document as stored in CouchDB. Some keys
    # that are hard to type or remember (e.g., @id, @type) are available as
    # symbols (i.e., :id, :type). The CouchDB _id is changed to :doc_id.
    #
    class Schema < Hashie::Thrash
      include Hashie::Extensions::Coercion
      include ActiveModel::Validations
      include Hashie::Extensions::MergeInitializer

      property :doc_id, from: '_id'
      property :doc_rev, from: '_rev'
      property :id, from: '@id'
      property :context, from: '@context'
      property :type, from: '@type', default: 'Document'

      validates_presence_of :type
    end

    # Class that models a user Identity
    #
    class Identity < Schema
      property :id, from: '@id', default: ''
      property :context, from: '@context', default: 'contexts/identity/v1'
      property :type, from: '@type', default: 'Identity'

      property :password, from: 'password'

      property :created, from: 'created', default: Time.now.utc.iso8601
      property :updated, from: 'updated', default: Time.now.utc.iso8601

      property :token, from: 'token'

      validates_presence_of :password

      validate :username_format

      def version!
        updated = self[:updated]
        v_t = Time.iso8601(updated).to_i
        v_r = SecureRandom.hex(2)
        v_s = '::v' + v_t.to_s + '-' + v_r.to_s
        self[:doc_rev] = nil
        self[:doc_id] = self[:doc_id] + v_s
      end

      def update!
        self[:updated] = Time.now.utc.iso8601
      end

      def username
        self[:id].sub(self.class.id_prefix, '')
      end

      def username=(name)
        unless name.nil?
          self.doc_id = self.class.doc_prefix + name
          self.id = self.class.id_prefix + name
        end
      end

      def username_format
        has_one_letter = username =~ /[a-zA-Z]/
        all_valid_characters = username =~ /^[a-zA-Z0-9_]+$/
        msg = 'must have at least one letter and contain only letters, digits, or underscores'
        errors.add(:username, msg) unless has_one_letter && all_valid_characters
      end

      def new_password=(password)
        self.password = nil
        if !password.nil? && !password.empty?
          self.password = BCrypt::Password.create(password)
        end
      end

      def password_match?(password)
        BCrypt::Password.new(self[:password]) == password
      end

      private

      def self.doc_prefix
        'identity' + ':'
      end

      def self.id_prefix
        'users' + '/'
      end
    end

    # Class that models a Schema.org Thing, the top-level object in the type
    # hierarchy.
    #
    class Thing < Schema
      property :context, from: '@context', default: 'http://schema.org'
      property :type, from: '@type', default: 'Thing'

      property :url, from: 'url'

      property 'description'
      property 'name'

      property :same_as, from: 'sameAs'

      # URL validation can exclude Thing subclasses that do it themselves
      validates :url, format: /\A#{URI.regexp}\z/, allow_blank: true,
                      unless: (proc do |t|
                        t.type == 'WebPage' ||
                        t.type == 'ItemPage'
                      end)

      def slug
        self[:id].sub(self.class.id_prefix, '')
      end

      def slug=(id)
        unless id.nil? || id.empty?
          self.doc_id = self.class.doc_prefix + id
          self.id = self.class.id_prefix + id
        end
      end

      private

      def self.doc_prefix
        'thing' + ':'
      end

      def self.id_prefix
        'things' + '/'
      end
    end

    # Class that models a Schema.org Person
    #
    class Person < Thing
      property :type, from: '@type', required: true, default: 'Person'
    end

    # Class that models a Schema.org CreativeWork
    #
    class CreativeWork < Thing
      property :context, from: '@context', default: 'contexts/work/v1'
      property :type, from: '@type', required: true, default: 'CreativeWork'

      property :name, from: 'name'
      property 'creator'
      property 'license'
      property 'dateCreated'
      property 'about'

      property 'firstReviewed', default: Time.now.utc.iso8601
      property 'lastReviewed', default: Time.now.utc.iso8601
      property 'reviewedBy'

      property :is_based_on_url, from: 'isBasedOnUrl'

      validates_presence_of :name, unless: proc { |c| c.type != 'CreativeWork' }
      validates :is_based_on_url, format: /\A#{URI.regexp}\z/, allow_blank: true

      def update!
        self['lastReviewed'] = Time.now.utc.iso8601
      end

      def version!
        updated = self['lastReviewed']
        v_t = Time.iso8601(updated).to_i
        v_r = SecureRandom.hex(2)
        v_s = '::v' + v_t.to_s + '-' + v_r.to_s
        self[:doc_rev] = nil
        self[:doc_id] = self[:doc_id] + v_s
      end

      def name
        self[:name]
      end

      def template
        self.class.template(self)
      end

      def links
        if self['reviewedBy'].is_a? String
          [{ href: '/' + self['reviewedBy'], rel: 'reviewedBy', prompt: 'Reviewer' }]
        else
          []
        end
      end

      def items
        data = self.class.items_template(self).reject do |d|
          value = d.last[:value]
          value.nil? || value.empty?
        end
        data << ['lastReviewed', { prompt: 'Date Reviewed', value: self['lastReviewed'] }]
      end

      def href
        id = self[:id]
        '/' + id if id.is_a? String
      end

      private

      def self.doc_prefix
        'creative_work' + ':'
      end

      def self.id_prefix
        'works' + '/'
      end

      def self.template(entity = {})
        items_template(entity) + links_template(entity)
      end

      def self.items_template(entity = {})
        [['name', { prompt: 'Title', value: entity[:name] }],
         ['creator', { prompt: 'Creator', value: entity['creator'] }],
         ['license', { prompt: 'License', value: entity['license'] }],
         ['dateCreated', { prompt: 'Date Created', value: entity['dateCreated'] }]]
      end

      def self.links_template(_entity = {})
        []
      end

      def self.whitelist(data)
        keys = template.map(&:first)
        data.select { |k, _v| keys.include?(k) }
      end
    end

    # Class that models a Schema.org WebPage
    #
    class WebPage < CreativeWork
      property :type, from: '@type', required: true, default: 'WebPage'

      property 'lastReviewed', default: Time.now.utc.iso8601

      property :work, from: 'hasPart'
      property :reviewedBy, from: 'reviewedBy'

      coerce_key :reviewedBy, Person
      coerce_key :work, CreativeWork

      validates :url, format: /\A#{URI.regexp}\z/, allow_blank: false

      validate :part_valid

      private

      def part_valid
        work_is_valid = work.valid?
        work_err_messages = work.errors.full_messages.join(', ')
        errors.add(:work, work_err_messages) unless work_is_valid
      end
    end

    # Class that models a Schema.org ItemPage
    # It does not inherit from WebPage as to not conflict with the current use of
    # that model.
    #
    class ItemPage < CreativeWork
      property :context, from: '@context', default: 'contexts/webpage/v1'
      property :type, from: '@type', required: true, default: 'ItemPage'

      property 'author'
      property 'publisher'
      property 'datePublished'
      property :associated_media, from: 'associatedMedia'

      validates :url, format: /\A#{URI.regexp}\z/, allow_blank: false
      validates :associated_media, format: /\A#{URI.regexp}\z/, allow_blank: true

      def links
        lks = []
        lks << { href: self[:url], rel: 'external', prompt: 'URL' }
        unless self[:associated_media].nil? || self[:associated_media].empty?
          lks << { href: self[:associated_media], rel: 'external', prompt: 'Media' }
        end
        unless self[:is_based_on_url].nil? || self[:is_based_on_url].empty?
          lks << { href: self[:is_based_on_url], rel: 'external', prompt: 'Based on' }
        end
        if self['about'].is_a? String
          lks << { href: '/' + self['about'], rel: 'about', prompt: 'Creative Work' }
        end
        lks.push(*super)
      end

      private

      # Override from CreativeWork, since associatedMedia has its own validation
      # as a URL. This can be removed when the method no longer exists in the
      # superclass.
      def media_valid
        true
      end

      def self.id_prefix
        'webpages' + '/'
      end

      def self.items_template(entity = {})
        [['name', { prompt: 'Web Page Title', value: entity[:name] }],
         ['creator', { prompt: 'Credit (creator of the work)', value: entity['creator'] }],
         ['license', { prompt: 'License (as stated)', value: entity['license'] }],
         ['description', { prompt: 'Description', value: entity['description'] }],
         ['datePublished', { prompt: 'Date Published', value: entity['datePublished'] }],
         ['publisher', { prompt: 'Publisher', value: entity['publisher'] }]]
      end

      def self.links_template(entity = [])
        lks = super
        lks << ['url', { prompt: 'Web Page URL (required)', value: entity[:url] }]
        lks << ['associatedMedia',
                { prompt: 'Media File URL', value: entity[:associated_media] }]
        lks << ['isBasedOnUrl',
                { prompt: 'Based on URL (link to original source)',
                  value: entity[:is_based_on_url] }]
      end

      def self.whitelist(data)
        keys = template.map(&:first)
        keys << 'about'
        data.select { |k, _v| keys.include?(k) }
      end
    end

    # Class that models a Schema.org WebPageElement
    #
    class WebPageElement < ItemPage
      property :type, from: '@type', required: true, default: 'WebPageElement'

      property 'caption'

      def self.items_template(entity = {})
        tpl = [['caption', { prompt: 'Caption', value: entity['caption'] }],
               ['author', { prompt: 'Web Page Author', value: entity['author'] }]]
        tpl.push(*super)
      end

      private

      def self.id_prefix
        'elements' + '/'
      end
    end

    # Class that models a Schema.org MediaObject
    #
    class MediaObject < CreativeWork
      property :type, from: '@type', required: true, default: 'MediaObject'

      property :content_url, from: 'contentUrl'

      validates :content_url, format: /\A#{URI.regexp}\z/, allow_blank: false
    end

    class CreativeWork < Thing
      property :media, from: 'associatedMedia'

      coerce_key :media, MediaObject

      validate :media_valid

      private

      def media_valid
        unless media.nil?
          media_is_valid = media.valid?
          media_err_messages = media.errors.full_messages.join(', ')
          errors.add(:media, media_err_messages) unless media_is_valid
        end
      end
    end
  end
end