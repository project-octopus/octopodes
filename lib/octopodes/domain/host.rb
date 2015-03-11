module Octopodes
  module Domain
    # Models a Host
    class Host
      attr_accessor :hostname, :count

      def initialize(data)
        @hostname = data[:hostname]
        @count = data[:count]
      end

      def href
        'hosts/' + URI.encode(hostname)
      end

      def data
        [[:hostname, { prompt: 'Host', value: hostname }],
         [:count, { prompt: 'Count', value: count }]]
      end

      def template
        []
      end

      def links
        []
      end
    end
  end
end
