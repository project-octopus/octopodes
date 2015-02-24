require 'spec_helper'
require 'octopodes/domain/thing'

module Octopodes
  # Test for Thing model
  module Domain
    describe Thing do
      let(:name) { 'Name' }
      let(:description) { 'Info' }
      let(:url) { 'http://example.com/test' }

      describe 'create' do
        subject { Thing.create(name: name) }

        context 'with all valid attributes' do
          it 'gets a type' do
            expect(subject.type).to eq 'Thing'
          end

          it 'gets a uuid' do
            uuid_regex = /([a-f\d]{8}(-[a-f\d]{4}){3}-[a-f\d]{12}?)/i
            expect(subject.uuid).to match uuid_regex
          end

          it 'gets timestamps' do
            expect(subject.created_at).to be_an_instance_of(Time)
            expect(subject.updated_at).to be_an_instance_of(Time)
          end
        end

        context 'with a non-allowed column' do
          subject { Thing.new(name: name, uuid: uuid) }
          let(:uuid) { '175beb55-b587-4fb0-a621-d9f1a23d01c9' }

          it 'does not throw an error' do
            expect { subject }.not_to raise_error
          end

          it 'does not set the unallowed column' do
            expect(subject.uuid).not_to eq uuid
          end
        end

        context 'with undefined extra params' do
          subject { Thing.new(name: name, xxx: 'Test') }

          it 'does not throw an error' do
            expect { subject }.not_to raise_error
          end
        end
      end

      describe 'updated_by' do
        context 'updated by a user' do
          subject(:thing) { Thing.create name: name }
          subject(:user) do
            User.create(username: username, password: password,
                        password_confirmation: password_confirmation)
          end

          let(:name) { 'A Thing' }
          let(:username) { 'a_user' }
          let(:password) { 'foo' }
          let(:password_confirmation) { 'foo' }

          it 'has a user' do
            thing.updated_by = user

            expect(thing.updated_by.username).to eq user.username
          end
        end
      end

      describe 'validate' do
        subject { Thing.new(name: name, url: url) }

        context 'with all valid attributes' do
          let(:url) { 'http://example.com/test' }

          it 'is valid' do
            expect(subject.valid?).to be true
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

        context 'with a long URL' do
          let(:url) do
            path = ''
            2049.times { path << ((rand(2) == 1 ? 65 : 97) + rand(25)).chr }
            'http://example.org/' + path
          end

          it 'is not valid' do
            expect(subject.valid?).to be false
          end

          it 'has an error' do
            subject.valid?
            expect(subject.errors.size).to eq 1
            expect(subject.errors).to include :url
          end
        end

        context 'with a non-unique UUID' do
          subject do
            t1 = Thing.create(name: 'T1')
            t2 = Thing.new(name: 'T2')
            t2.uuid = t1.uuid
            t2
          end

          it 'is not valid' do
            expect(subject.valid?).to be false
          end

          it 'has an error' do
            subject.valid?
            expect(subject.errors.size).to eq 1
            expect(subject.errors).to include :uuid
          end
        end
      end

      describe 'data' do
        subject do
          Thing.new(name: name, description: description, url: url).data
        end

        context 'with name and description' do
          it 'lists the name and description' do
            expected = [[:name, { prompt: 'Name', value: 'Name' }],
                        [:description, { prompt: 'Description', value: 'Info' }]]
            expect(subject).to match expected
          end
        end

        context 'with name but empty description' do
          let(:description) { '' }
          it 'lists the name but nothing for description' do
            expected = [[:name, { prompt: 'Name', value: 'Name' }]]
            expect(subject).to match expected
          end
        end
      end

      describe 'links' do
        subject { Thing.new(name: name, url: url).links }

        context 'with a url set' do
          let(:url) { 'http://example.org/link' }

          it 'lists the links' do
            # TODO: expected = [{ href: url, rel: 'external', prompt: 'URL' }]
            expected = [{ href: url, prompt: 'URL' }]
            expect(subject).to match expected
          end
        end

        context 'with no url set' do
          let(:url) { '' }

          it 'lists no links' do
            expected = []
            expect(subject).to match expected
          end
        end
      end

      describe 'template' do
        subject { Thing.new(name: name).template }

        it 'provides a template for the model' do
          expected = [:name, { prompt: 'Name', value: name }]
          expect(subject.first).to match expected
        end
      end

      describe 'class.template' do
        subject { Thing.template }

        it 'provides a blank template' do
          expected = [:name, { prompt: 'Name', value: '' }]
          expect(subject.first).to match expected
        end
      end

      describe 'class.type' do
        subject { Thing.type }

        it 'provides the type of the class for CTI purposes' do
          expect(subject).to eq 'Thing'
        end
      end

      describe 'identifier' do
        subject { Thing.create(name: name) }

        it 'is the same as the uuid' do
          expect(subject.identifier).to eq subject.uuid
        end
      end
    end
  end
end
