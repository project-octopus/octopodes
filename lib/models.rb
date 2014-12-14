require 'hashie'
require 'active_model'

require_relative 'thrash'

# Class that models a Schema.org Thing, the top-level object in the type
# hierarchy. It can be created using a Ruby hash represeting a JSON-LD
# document. Some keys that are difficult to work with such as @id, @type,
# and @context are converted to symbols. A CouchDB _id is changed to :doc_id.
# Any keys that require validation like "url" are also made into symbols.
#
class Thing < Thrash
  include Hashie::Extensions::Coercion
  include ActiveModel::Validations

  property :doc_id, from: "_id"
  property :id, from: "@id"
  property :context, from: "@context", default: 'http://schema.org'
  property :type, from: "@type", default: "Thing"

  property :url, from: 'url'

  property 'description'
  property 'name'

  validates_presence_of :type

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
