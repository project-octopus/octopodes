require 'hashie'
require 'active_model'
require 'bcrypt'

require_relative 'thrash'

# Class that models a JSON-LD document as stored in CouchDB. Some keys
# that are hard to type or remember (e.g., @id, @type) are available as
# symbols (i.e., :id, :type). The CouchDB _id is changed to :doc_id.
#
class Schema < Thrash
  include Hashie::Extensions::Coercion
  include ActiveModel::Validations

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
  property :username, from: "@id"
  property :context, from: "@context", default: 'https://w3id.org/identity/v1'
  property :type, from: "@type", default: "Identity"

  property :password, from: "password"

  property 'created', default: Time.now.utc.iso8601

  validates_presence_of :username, :password

  def new_password=(password)
    if !password.nil? && !password.empty?
      self.password = BCrypt::Password.create(password)
    end
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
  property :type, from: "@type", required: true, default: "CreativeWork"

  property 'creator'
  property 'license'

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
