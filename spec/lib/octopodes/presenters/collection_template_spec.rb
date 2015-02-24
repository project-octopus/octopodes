require 'spec_helper'
require 'octopodes/presenters/collection_template'

module Octopodes
  module Presenters
    # Test Collection
    describe CollectionTemplateDecoder do
      subject do
        CollectionTemplateDecoder.new(json)
      end

      describe 'valid' do
        context 'with nil data' do
          let(:json) { nil }

          it 'is not valid' do
            expect(subject.valid?).to be false
            expect(subject.error).not_to be nil
          end
        end

        context 'with empty string' do
          let(:json) { '' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with empty json object' do
          let(:json) { '{}' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with empty template object' do
          let(:json) { '{"template":{}}' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with empty template data array' do
          let(:json) { '{"template":{"data":[]}}' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end
      end

      describe 'to_hash' do
        context 'with nil data' do
          let(:json) { nil }

          it 'is an empty hash' do
            expect(subject.to_hash).to match({})
          end
        end

        context 'with collection json template string with data' do
          let(:json) { '{"template":{"data":[{"name": "a", "value": "1"}]}}' }

          it 'is a hash' do
            expect(subject.to_hash).to match('a' => '1')
          end
        end
      end
    end
  end
end
