require 'spec_helper'
require 'octopodes/domain/creative_work'

module Octopodes
  # Test for Creative Work model
  module Domain
    describe CreativeWork do
      describe 'is_part_of' do
        context 'with a work being part of another work' do
          subject(:work) { CreativeWork.create name: 'A Big Work' }
          subject(:part) { CreativeWork.create name: 'A Part of a Work' }

          it 'is a part' do
            part.is_part_of = work

            expect(part.is_part_of.name).to eq work.name
          end

          it 'has a parent with one part' do
            work.add_has_part(part)

            expect(work.has_part.first.name).to eq part.name
          end
        end
      end

      describe 'example_of_work' do
        context 'with a work having an example/realization/derivation' do
          subject(:work) { CreativeWork.create name: 'An Original Work' }
          subject(:example) do
            CreativeWork.create name: 'A Derivative of a Work'
          end

          it 'is an example' do
            example.example_of_work = work

            expect(example.example_of_work.name).to eq work.name
          end

          it 'has an example' do
            work.add_work_example(example)

            expect(work.work_example.first.name).to eq example.name
          end
        end
      end

      describe 'validate' do
        subject(:work) do
          CreativeWork.new name: 'A Big Work', is_based_on_url: url,
                           associated_media: media
        end

        context 'with a bad based on URL' do
          let(:url) { 'xxx' }
          let(:media) { '' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end

          it 'has an error' do
            subject.valid?
            expect(subject.errors.size).to eq 1
            expect(subject.errors).to include :is_based_on_url
          end
        end

        context 'with a bad media URL' do
          let(:url) { '' }
          let(:media) { 'xxx' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end

          it 'has an error' do
            subject.valid?
            expect(subject.errors.size).to eq 1
            expect(subject.errors).to include :associated_media
          end
        end
      end

      describe 'data' do
        subject(:creative_work) { CreativeWork.new(name: 'A Work').data }

        it 'lists data' do
          expected = [[:name, { prompt: 'Title', value: 'A Work' }]]
          expect(subject).to match expected
        end
      end

      describe 'href' do
        subject(:creative_work) do
          CreativeWork.new(name: 'CW').tap { |c| c.uuid = uuid }.href
        end
        let(:uuid) { '2e433d6d-db72-4445-92b6-e48d605caa18'  }

        it 'makes a path with the class name and the uuid' do
          expect(subject).to eq "schema/creative-works/#{uuid}"
        end
      end
    end
  end
end
