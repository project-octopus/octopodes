require 'spec_helper'
require 'octopodes/domain/web_page'

module Octopodes
  # Test for Webpage model
  module Domain
    describe WebPage do
      subject { WebPage.new url: url }
      let(:url) { 'http://example.org' }

      describe 'validate' do
        context 'with all valid attributes' do
          it 'is valid' do
            expect(subject.valid?).to be true
          end
        end

        context 'with no URL' do
          let(:url) { nil }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end

          it 'has an error' do
            subject.valid?
            expect(subject.errors.size).to eq 1
            expect(subject.errors).to include :url
          end
        end

        context 'with a bad URL' do
          let(:url) { 'xxx' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end

          it 'has an error' do
            subject.valid?
            expect(subject.errors.size).to eq 1
            expect(subject.errors).to include :url
          end
        end
      end

      describe 'data' do
        subject { WebPage.new(name: 'A Webpage', url: url).data }

        it 'lists data' do
          expected = [[:name, { prompt: 'Title', value: 'A Webpage' }]]
          expect(subject).to match expected
        end
      end
    end
  end
end
