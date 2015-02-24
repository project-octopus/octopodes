require 'spec_helper'
require 'octopodes/presenters/collection'

module Octopodes
  module Presenters
    # Test Collection
    describe Collection do
      subject do
        Collection.new(dataset, options)
      end

      describe 'to_cj' do
        context 'with no data' do
          let(:dataset) { [] }
          let(:options) { {} }

          it 'generates a CollectionJSON Collection' do
            expect(subject.to_cj).to be_a(CollectionJSON::Collection)
          end
        end
      end
    end
  end
end
