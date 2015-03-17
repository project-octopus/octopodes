require 'spec_helper'
require 'octopodes/presenters/www_form'

module Octopodes
  module Presenters
    # Test Collection
    describe WwwFormDecoder do
      subject do
        WwwFormDecoder.new(url_encoded_data)
      end

      describe 'valid' do
        context 'with nil data' do
          let(:url_encoded_data) { nil }

          it 'is valid' do
            expect(subject.valid?).to be true
          end
        end

        context 'with empty data' do
          let(:url_encoded_data) { '' }

          it 'is valid' do
            expect(subject.valid?).to be true
          end
        end

        context 'with bad data' do
          let(:url_encoded_data) { 'xxx' }

          it 'is not valid' do
            expect(subject.valid?).to be false
            expect(subject.error).not_to be nil
          end
        end
      end

      describe 'to_hash' do
        context 'with nil data' do
          let(:url_encoded_data) { nil }

          it 'is empty' do
            expect(subject.to_hash).to match({})
          end
        end

        context 'with empty data' do
          let(:url_encoded_data) { '' }

          it 'is empty' do
            expect(subject.to_hash).to match({})
          end
        end

        context 'with data' do
          let(:url_encoded_data) { 'a=1&b=2' }

          it 'is a hash' do
            expect(subject.to_hash).to match('a' => '1', 'b' => '2')
          end
        end

        context 'with leading and trailing whitespace in values' do
          let(:url_encoded_data) { 'a=%201%20&b=2' }

          it 'strips the strings' do
            expect(subject.to_hash).to match('a' => '1', 'b' => '2')
          end
        end

        context 'with array-designated keys' do
          let(:url_encoded_data) { 'a=1&b%5B%5D=2&b%5B%5D=3' }

          it 'makes repeats into an array' do
            expect(subject.to_hash).to match('a' => '1', 'b' => ['2', '3'])
          end
        end
      end
    end
  end
end
