require 'spec_helper'
require 'octopodes/presenters/atom'

module Octopodes
  module Presenters
    # Test Atom
    describe Atom do
      subject do
        Atom.new(dataset, options)
      end

      describe 'to_s' do
        context 'with no data' do
          let(:dataset) { [] }
          let(:options) { {} }

          it 'generates an ATOM XML document' do
            expect(subject.to_s).to include 'xml version'
          end
        end
      end
    end
  end
end
