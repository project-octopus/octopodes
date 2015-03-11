require 'spec_helper'
require 'octopodes/domain/host'

module Octopodes
  # Test for Host model
  module Domain
    describe Host do
      let(:data) { { hostname: 'example.org', count: 2 } }

      describe 'href' do
        subject { Host.new(data).href }
        it 'puts in in the hosts resource' do
          expect(subject).to eq 'hosts/example.org'
        end
      end

      describe 'data' do
        subject { Host.new(data).data }
        it 'shows data for hostname and count' do
          expected = [[:hostname, { prompt: 'Host', value: data[:hostname] }],
                      [:count, { prompt: 'Count', value: data[:count] }]]
          expect(subject).to eq expected
        end
      end

      describe 'links' do
        subject { Host.new(data).links }
        it 'has empty links' do
          expect(subject).to eq []
        end
      end

      describe 'template' do
        subject { Host.new(data).template }
        it 'has empty template' do
          expect(subject).to eq []
        end
      end
    end
  end
end
