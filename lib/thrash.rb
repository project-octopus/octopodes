require 'hashie'

# A Thrash is a Hashie::Trash where transformed keys are mapped back to
# their original names when generating a hash.
#
class Thrash < Hashie::Trash

  alias_method :to_hash_original, :to_hash

  def to_hash
    hash = to_hash_original

    self.class.inverse_translations.each do |k,v|
      unless hash[k].nil?
        hash[v] = hash[k]
      end
      hash.delete(k)
    end

    hash
  end
end
