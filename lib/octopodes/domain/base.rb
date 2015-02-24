module Octopodes
  module Domain
    # Adds methods to any domain class.
    #
    #   class Thing < Sequel::Model
    #     include Octopodes::Domain::Base
    #   end
    module Base
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        attr_reader :prompts, :data_columns, :link_columns

        # rubocop:disable Style/TrivialAccessors, Style/AccessorMethodName

        # Set the Prompts corresponding to the data columns
        #
        #   Thing.set_prompts(name: 'Title')
        #   Thing.prompts[:name] # 'Title'
        def set_prompts(prompts)
          @prompts = prompts
        end

        # Specify which columns are for data
        def set_data_columns(*cols)
          @data_columns = cols
        end

        # Specify which columns are for links
        def set_link_columns(*cols)
          @link_columns = cols
        end

        # rubocop:enable Style/TrivialAccessors, Style/AccessorMethodName

        # Create a template for the domain with name, prompt, and value
        def template
          cols = allowed_columns ? allowed_columns : []

          cols.map do |c|
            pmpts = prompts ? prompts : {}
            prompt = pmpts[c] ? pmpts[c] : c.to_s.humanize
            [c, { prompt: prompt, value: '' }]
          end
        end
      end

      # List data for the domain object by name, value, and prompt,
      #   removing any blanks. Picks columns defined in `data_columns`
      #   and falls back to `allowed_columns`.
      #
      #   Thing.new(name: 'The Title').data
      #   # => [['name', { prompt: 'Title', value: 'The Title' }]]
      def data
        klass = self.class
        allowed_cols = klass.allowed_columns ? klass.allowed_columns : []
        data_cols = klass.data_columns ? klass.data_columns : []

        cols = data_cols ? data_cols : allowed_cols
        cols.reject { |c| send(c).blank? }.map do |c|
          prompts = self.class.prompts ? self.class.prompts : {}
          prompt = prompts[c] ? prompts[c] : c.to_s.humanize
          [c, { prompt: prompt, value: send(c) }]
        end
      end

      # List links for the domain object by href, rel, prompt, and name
      def links
        cols = self.class.link_columns ? self.class.link_columns : []
        cols.reject { |c| send(c).blank? }.map do |c|
          prompts = self.class.prompts ? self.class.prompts : {}
          prompt = prompts[c] ? prompts[c] : c.to_s.humanize
          { href: send(c), prompt: prompt }
        end
      end

      # Create a template for the domain object with name, prompt, and value
      def template
        klass = self.class
        cols = klass.allowed_columns ? klass.allowed_columns : []

        cols.map do |c|
          prompts = self.class.prompts ? self.class.prompts : {}
          prompt = prompts[c] ? prompts[c] : c.to_s.humanize
          value = send(c)
          [c, { prompt: prompt, value: value ? value : '' }]
        end
      end
    end
  end
end
