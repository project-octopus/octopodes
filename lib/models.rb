require 'hashie'
require 'active_model'
require 'bcrypt'
require 'securerandom'

require_relative 'thrash'

# Class that models a JSON-LD document as stored in CouchDB. Some keys
# that are hard to type or remember (e.g., @id, @type) are available as
# symbols (i.e., :id, :type). The CouchDB _id is changed to :doc_id.
#
class Schema < Thrash
  include Hashie::Extensions::Coercion
  include ActiveModel::Validations
  include Hashie::Extensions::MergeInitializer

  property :doc_id, from: "_id"
  property :doc_rev, from: "_rev"
  property :id, from: "@id"
  property :context, from: "@context"
  property :type, from: "@type", default: "Document"

  validates_presence_of :type
end

# Class that models a user Identity
#
class Identity < Schema

  property :id, from: "@id", default: ''
  property :context, from: "@context", default: 'contexts/identity/v1'
  property :type, from: "@type", default: "Identity"

  property :password, from: "password"

  property :created, from: "created", default: Time.now.utc.iso8601
  property :updated, from: "updated", default: Time.now.utc.iso8601

  property :token, from: "token"

  validates_presence_of :password

  validate :username_format

  def version!
    updated = self[:updated]
    v_t = Time.iso8601(updated).to_i
    v_r = SecureRandom.hex(2)
    v_s = "::v" + v_t.to_s + '-' + v_r.to_s
    self[:doc_rev] = nil
    self[:doc_id] = self.doc_id + v_s
  end

  def update!
    self[:updated] = Time.now.utc.iso8601
  end

  def username
    self.id.sub(id_prefix, '')
  end

  def username=(name)
    unless name.nil?
      self.doc_id = doc_prefix + name
      self.id = id_prefix + name
    end
  end

  def username_format
    has_one_letter = username =~ /[a-zA-Z]/
    all_valid_characters = username =~ /^[a-zA-Z0-9_]+$/
    errors.add(:username, "must have at least one letter and contain only letters, digits, or underscores") unless (has_one_letter and all_valid_characters)
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
  def doc_prefix
    'identity' + ':'
  end

  def id_prefix
    'users' + '/'
  end
end

# Class that models a Schema.org Thing, the top-level object in the type
# hierarchy.
#
class Thing < Schema
  property :context, from: "@context", default: 'http://schema.org'
  property :type, from: "@type", default: "Thing"

  property :url, from: 'url'

  property 'description'
  property 'name'

  property :same_as, from: 'sameAs'

  # URL validation can exclude Thing subclasses that do it themselves
  validates :url, :format => /\A#{URI::regexp}\z/, :allow_blank => true,
                  :unless => Proc.new {|thing| thing.type == "WebPage" }
end

# Class that models a Schema.org Person
#
class Person < Thing
  property :type, from: "@type", required: true, default: "Person"
end

# Class that models a Schema.org CreativeWork
#
class CreativeWork < Thing
  property :context, from: "@context", default: 'contexts/work/v1'
  property :type, from: "@type", required: true, default: "CreativeWork"

  property 'creator'
  property 'license'
  property 'dateCreated'

  property 'firstReviewed', default: Time.now.utc.iso8601
  property 'lastReviewed', default: Time.now.utc.iso8601
  property 'reviewedBy'

  property :based_on_url, from: 'isBasedOnUrl'

  validates :based_on_url, :format => /\A#{URI::regexp}\z/, :allow_blank => true
end

# Class that models a Schema.org WebPage
#
class WebPage < CreativeWork
  property :type, from: "@type", required: true, default: "WebPage"

  property 'lastReviewed', default: Time.now.utc.iso8601

  property :work, from: 'hasPart'
  property :reviewedBy, from: 'reviewedBy'

  coerce_key :reviewedBy, Person
  coerce_key :work, CreativeWork

  validates :url, :format => /\A#{URI::regexp}\z/, :allow_blank => false

  validate :part_valid

  private
  def part_valid
    work_is_valid = self.work.valid?
    work_err_messages = self.work.errors.full_messages.join(", ")
    errors.add(:work, work_err_messages) unless work_is_valid
  end
end

# Class that models a Schema.org MediaObject
#
class MediaObject < CreativeWork
  property :type, from: "@type", required: true, default: "MediaObject"

  property :content_url, from: "contentUrl"

  validates :content_url, :format => /\A#{URI::regexp}\z/, :allow_blank => false
end

class CreativeWork < Thing
  property :media, from: 'associatedMedia'

  coerce_key :media, MediaObject

  validate :media_valid

  private
  def media_valid
    if !self.media.nil?
      media_is_valid = self.media.valid?
      media_err_messages = self.media.errors.full_messages.join(", ")
      errors.add(:media, media_err_messages) unless media_is_valid
    end
  end
end
