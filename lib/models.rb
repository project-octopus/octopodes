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

  validates :url, :format => /\A#{URI::regexp}\z/, :allow_blank => true
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
  property 'isBasedOnUrl'
  property 'license'
end

# Class that models a Schema.org WebPage
#
class WebPage < CreativeWork
  property :type, from: "@type", required: true, default: "WebPage"

  property 'lastReviewed', default: Time.now.utc.iso8601

  property 'hasPart'
  property 'reviewedBy'

  coerce_key :reviewedBy, Person
  coerce_key :hasPart, CreativeWork

  validates_presence_of :id, :doc_id
end
