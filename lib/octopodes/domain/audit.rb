require 'octopodes/db'

module Octopodes
  module Domain
    # Domain to model the Audit table
    class Audit < Sequel::Model(:audit__logged_actions)
    end
  end
end
