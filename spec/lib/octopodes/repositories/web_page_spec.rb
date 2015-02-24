require 'spec_helper'
require 'octopodes/repositories/web_page'

module Octopodes
  # Test for Creative Work Repository
  module Repositories
    describe WebPage do
      describe 'new' do
        subject { Repositories::WebPage.new }

        context 'with no arguments' do
          it 'returns a new webpage' do
            expect(subject).to be_a(Domain::WebPage)
          end
        end
      end

      describe 'create' do
        subject { Repositories::WebPage.create(uuid, data) }

        context 'with valid data' do
          let(:uuid) { 'd53b184a-346a-41ae-8687-438f4e81cf13' }
          let(:data) { { name: 'WD', url: 'http://example.org/d' } }

          it 'creates and returns a webpage' do
            expect(subject.valid?).to be true
            expect(subject.uuid).to eq uuid
            expect(subject.name).to eq data[:name]
          end
        end
      end

      describe 'update' do
        subject { Repositories::WebPage.update(uuid, data) }

        context 'with valid data' do
          let(:uuid) { '8a3a340a-7eea-43a7-9876-be4565cd7846' }
          let(:data) { { name: 'WA New', url: 'http://example.org/new' } }

          it 'updates and returns a webpage' do
            load(:web_pages)
            expect(subject.valid?).to be true
            expect(subject.name).to eq data[:name]
            expect(subject.url).to eq data[:url]
          end
        end
      end

      describe 'recent' do
        subject { Repositories::WebPage.recent(options) }

        context 'with no options' do
          let(:options) { {} }

          it 'returns all recent webpages' do
            load(:web_pages)
            expect(subject.count).to eq 2
          end

          it 'returns webpages most recent first' do
            load(:web_pages)
            expect(subject.first.id).to eq 5
            expect(subject.last.id).to eq 4
          end
        end

        context 'with limit 1' do
          let(:options) { { limit: 1 } }

          it 'returns 1 work' do
            load(:web_pages)
            expect(subject.count).to eq 1
          end
        end
      end

      describe 'count' do
        subject { Repositories::WebPage.count }

        it 'returns the number of webpages' do
          load(:web_pages)
          expect(subject).to eq 2
        end
      end
    end
  end
end
