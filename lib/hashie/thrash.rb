require 'hashie'

module Hashie
  # A Thrash is a Hashie::Trash where transformed keys are mapped back to
  # their original names when generating a hash.
  #
  class Thrash < Trash
    alias_method :to_hash_original, :to_hash

    def to_hash
      hash = to_hash_original

      self.class.inverse_translations.each do |k, v|
        hash[v] = hash[k] unless hash[k].nil?
        hash.delete(k)
      end

      hash
    end
  end
end
