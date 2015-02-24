require 'octopodes/db'

module Octopodes
  module Domain
    # Domain to model a User
    class User < Sequel::Model
      plugin :timestamps, update_on_create: true

      plugin :validation_helpers

      plugin :secure_password

      def validate
        super
        validates_presence :username
        validates_unique :username
        validates_max_length 255, :email, allow_blank: true

        bad_username_msg = 'must begin with a letter or digit and only ' \
                           'contain 3-40 letters, digits, or underscores'
        validates_format(/^(?!_)\w{3,40}$/, :username,
                         message: bad_username_msg)
      end

      def identifier
        username
      end

      def template
        @template = []

        # Only provide a username input if the user does not exist
        if id.nil?
          u_tpl = ['username', { prompt: 'Username', value: username }]
          @template << u_tpl
        end

        @template << ['password', { prompt: 'Password', value: '' }]
      end

      def self.template
        [['username', { prompt: 'Username', value: '' }],
         ['password', { prompt: 'Password', value: '' }]]
      end

      def data
        [['username', { prompt: 'Username', value: username }],
         ['created_at', { prompt: 'Member Since', value: created_at }]]
      end

      def links
        []
      end

      # Formulate an href for this model
      def href
        'users/' + identifier if identifier
      end
    end
  end
end
