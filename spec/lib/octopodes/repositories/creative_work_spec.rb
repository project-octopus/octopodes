require 'spec_helper'
require 'octopodes/repositories/creative_work'
require 'octopodes/domain/user'

module Octopodes
  # Test for Creative Work Repository
  module Repositories
    describe CreativeWork do
      describe 'token' do
        subject { Repositories::CreativeWork.uuid }

        it 'generates a UUID' do
          uuid_regex = /([a-f\d]{8}(-[a-f\d]{4}){3}-[a-f\d]{12}?)/i
          expect(subject).to match uuid_regex
        end
      end

      describe 'new' do
        subject { Repositories::CreativeWork.new(data) }

        context 'with no data' do
          let(:data) { {} }
          it 'returns a new work' do
            expect(subject).to be_a(Domain::CreativeWork)
          end
        end

        context 'with data' do
          let(:data) { { name: 'Test' } }
          it 'returns a new work with data' do
            expect(subject).to be_a(Domain::CreativeWork)
            expect(subject.name).to eq data[:name]
          end
        end
      end

      describe 'create' do
        subject { Repositories::CreativeWork.create(uuid, data, user) }
        let(:user) { Domain::User.first }

        context 'with valid data' do
          let(:uuid) { 'd53b184a-346a-41ae-8687-438f4e81cf13' }
          let(:data) { { name: 'CD' } }

          it 'creates and returns a work' do
            load(:user__user1)
            expect(subject.valid?).to be true
            expect(subject.uuid).to eq uuid
            expect(subject.name).to eq data[:name]
            expect(subject.updated_by).to eq user
          end
        end

        context 'with invalid data' do
          let(:uuid) { 'd53b184a-346a-41ae-8687-438f4e81cf13' }
          let(:data) { { name: '' } }

          it 'returns a work with errors' do
            expect(subject.valid?).to be false
          end
        end
      end

      describe 'update' do
        subject { Repositories::CreativeWork.update(uuid, data, user) }
        let(:user) { Domain::User[2] }

        context 'with valid data' do
          let(:uuid) { 'cad36401-2e13-47ac-90b8-547937ec254b' }
          let(:data) { { name: 'CA New', creator: 'A New Creator' } }

          it 'updates and returns a work' do
            load(:creative_works)
            load(:users)

            expect(subject.valid?).to be true
            expect(subject.name).to eq data[:name]
            expect(subject.creator).to eq data[:creator]
            expect(subject.updated_by).to eq user
          end
        end

        context 'with invalid data' do
          let(:uuid) { 'cad36401-2e13-47ac-90b8-547937ec254b' }
          let(:data) { { name: '' } }

          it 'returns a work with errors' do
            load(:creative_works)

            expect(subject.valid?).to be false
          end
        end
      end

      describe 'recent' do
        subject { Repositories::CreativeWork.recent(options) }

        context 'with no options' do
          let(:options) { {} }

          it 'returns all recent works' do
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

          it 'returns only creative works' do
            load(:creative_works)
            load(:web_pages)

            expect(subject.count).to eq 3
          end
        end
      end

      describe 'find' do
        subject { Repositories::CreativeWork.find(uuid) }

        context 'with an existing record' do
          let(:uuid) { 'cad36401-2e13-47ac-90b8-547937ec254b' }

          it 'returns a dataset with one work' do
            load(:creative_work__ca)
            expect(subject.count).to eq 1
            expect(subject.first.name).to eq 'CA'
          end
        end

        context 'with a non-existant record' do
          let(:uuid) { '93468c81-8365-4bbf-8e64-4ae37b320d7e' }

          it 'returns an empty dataset' do
            load(:creative_work__ca)
            expect(subject).to eq []
          end
        end
      end

      describe 'find_with_parts' do
        subject { Repositories::CreativeWork.find_with_parts(uuid) }

        context 'a work with one part' do
          let(:uuid) { 'c1fad786-dcc5-44c2-868a-eaf14ed95bc5' }

          it 'returns a dataset with one work and any parts' do
            load(:creative_work__cb, :creative_work__cc)
            expect(subject.count).to eq 2
            expect(subject.first.name).to eq 'CB'
            expect(subject.last.name).to eq 'CC'
          end
        end

        context 'a work with one example' do
          let(:uuid) { 'cad36401-2e13-47ac-90b8-547937ec254b' }

          it 'returns a dataset with one work and any examples' do
            load(:creative_work__cb, :creative_work__cc)
            expect(subject.count).to eq 2
            expect(subject.first.name).to eq 'CA'
            expect(subject.last.name).to eq 'CC'
          end
        end
      end

      describe 'update_provenance' do
        subject do
          Repositories::CreativeWork.update_provenance(uuid, data)
        end

        let(:uuid) { '33eae42b-5b47-46b2-b594-4905f5d049da' }
        let(:data) do
          { 'example_of_work' => 'c1fad786-dcc5-44c2-868a-eaf14ed95bc5',
            'is_part_of' => 'cad36401-2e13-47ac-90b8-547937ec254b' }
        end

        it 'updates the part of and example of' do
          load(:creative_works)
          expect(subject.is_part_of.uuid).to eq data['is_part_of']
          expect(subject.example_of_work.uuid).to eq data['example_of_work']
        end
      end

      describe 'count' do
        subject { Repositories::CreativeWork.count }

        it 'returns the number of works' do
          load(:creative_works)
          expect(subject).to eq 3
        end
      end
    end
  end
end
