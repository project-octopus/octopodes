require 'spec_helper'
require 'octopodes/repositories/thing'

module Octopodes
  # Test for Thing Repository
  module Repositories
    describe Thing do
      describe 'recent' do
        subject { Repositories::Thing.recent(options) }

        context 'with no options' do
          let(:options) { {} }

          it 'returns all recent things' do
            load(:creative_works)
            expect(subject.count).to eq 3
          end

          it 'returns works most recent first' do
            load(:creative_works)
            expect(subject.first.id).to eq 3
            expect(subject.last.id).to eq 1
          end
        end

        context 'with limit 1' do
          let(:options) { { limit: 1 } }

          it 'returns 1 work' do
            load(:creative_works)
            expect(subject.count).to eq 1
          end
        end

        context 'with startkeys' do
          let(:options) { { startkey: startkey } }
          let(:startkey) do
            '2015-02-28 13:12:51.550184,c1fad786-dcc5-44c2-868a-eaf14ed95bc5'
          end

          it 'returns works starting from the key' do
            load(:creative_works)
            expect(subject.count).to eq 1
            expect(subject.first.id).to eq 1
          end
        end

        context 'with creative works and webpages loaded' do
          let(:options) { {} }

          it 'returns only all works and webpages' do
            load(:creative_works)
            load(:web_pages)

            expect(subject.count).to eq 5
          end
        end
      end

      describe 'find_by_hostname' do
        subject { Repositories::Thing.find_by_hostname(hostname) }

        context 'with no hostname' do
          let(:hostname) {}

          it 'returns an empty set' do
            expect(subject).to eq []
          end
        end

        context 'with a hostname' do
          let(:hostname) { 'example.org' }

          it 'returns all things with that hostname' do
            load(:creative_works)
            load(:web_pages)
            expect(subject.count).to eq 2
          end
        end
      end

      describe 'count_by_hostname' do
        subject { Repositories::Thing.count_by_hostname(hostname) }

        context 'with a hostname' do
          let(:hostname) { 'example.org' }

          it 'counts the number of matching records' do
            load(:creative_works)
            load(:web_pages)
            expect(subject).to eq 2
          end
        end
      end
    end
  end
end
