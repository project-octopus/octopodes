require 'spec_helper'
require 'octopodes/repositories/host'

module Octopodes
  # Test for Thing Repository
  module Repositories
    describe Host do
      describe 'popular' do
        subject { Repositories::Host.popular(options) }

        context 'with no options' do
          let(:options) { nil }
          it 'lists all the domains' do
            load(:web_pages)
            load(:creative_works)
            expect(subject.count).to eq 2
          end

          it 'lists the most popular first' do
            load(:web_pages)
            load(:creative_works)
            expect(subject.first.hostname).to eq 'example.org'
            expect(subject.first.count).to eq 2
          end
        end
      end
    end
  end
end
