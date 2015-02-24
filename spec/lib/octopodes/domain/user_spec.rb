require 'spec_helper'
require 'octopodes/domain/user'

module Octopodes
  # Test for User model
  module Domain
    describe User do
      describe 'create' do
        subject do
          User.create(username: username, password: password,
                      password_confirmation: password_confirmation)
        end

        let(:username) { 'a_user' }
        let(:password) { 'foo' }
        let(:password_confirmation) { 'foo' }

        context 'with all valid attributes' do
          it 'gets timestamps' do
            expect(subject.created_at).to be_an_instance_of(Time)
            expect(subject.updated_at).to be_an_instance_of(Time)
          end
        end
      end

      describe 'validate' do
        let(:username) { 'a_user' }
        let(:password) { 'foo' }
        let(:password_confirmation) { 'foo' }

        subject do
          User.new(username: username, password: password,
                   password_confirmation: password_confirmation)
        end

        context 'with all valid attributes' do
          it 'is valid' do
            expect(subject.valid?).to be true
          end
        end

        context 'with no username' do
          let(:username) { nil }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with a long username' do
          let(:username) do
            str = ''
            41.times { str << ((rand(2) == 1 ? 65 : 97) + rand(25)).chr }
            str
          end

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with a short username' do
          let(:username) { 'aa' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with no letters in the username' do
          let(:username) { '42' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with a username not starting with letter or digit' do
          let(:username) { '_user' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with invalid characters in the username' do
          let(:username) { 'abc?' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with no password' do
          let(:password) { nil }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with a non-unique username' do
          subject do
            data = { username: 'abc', password: 'a', password_confirmation: 'a' }
            User.create(data)
            User.new(data)
          end

          it 'is not valid' do
            expect(subject.valid?).to be false
          end

          it 'has an error' do
            subject.valid?
            expect(subject.errors.size).to eq 1
            expect(subject.errors).to include :username
          end
        end

        context 'with no password confirmation' do
          let(:password_confirmation) { nil }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with non-matching password and confirmation' do
          let(:password_confirmation) { 'bar' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end

        context 'with an empty password' do
          let(:password) { '' }
          let(:password_confirmation) { '' }

          it 'is not valid' do
            expect(subject.valid?).to be false
          end
        end
      end

      describe 'authenticate' do
        subject do
          User.create(username: username, password: password,
                      password_confirmation: password_confirmation)
        end

        let(:username) { 'a_user' }
        let(:password) { 'foo' }
        let(:password_confirmation) { 'foo' }
        let(:incorrect_password) { 'bar' }

        context 'with correct password' do
          it 'authenticates' do
            expect(subject.authenticate(password)).to be subject
          end
        end

        context 'with incorrect password' do
          it 'authenticates' do
            expect(subject.authenticate(incorrect_password)).to be nil
          end
        end
      end

      describe 'template' do
        context 'when the user is new' do
          subject { User.new(username: username).template }

          let(:username) { 'a_user' }

          it 'provides a template for the model' do
            expected = ['username', { prompt: 'Username', value: username }]
            expect(subject.first).to match expected
          end
        end

        context 'when the user exists' do
          subject do
            User.create(username: username, password: password,
                        password_confirmation: password_confirmation).template
          end

          let(:username) { 'a_user' }
          let(:password) { 'foo' }
          let(:password_confirmation) { 'foo' }

          it 'provides a template without a username input' do
            expected = [['password', { prompt: 'Password', value: '' }]]
            expect(subject).to match expected
          end
        end
      end

      describe 'class.template' do
        subject { User.template }

        it 'provides a blank template' do
          expected = ['username', { prompt: 'Username', value: '' }]
          expect(subject.first).to match expected
        end
      end

      describe 'data' do
        subject { User.new(username: username).data }
        let(:username) { 'a_user' }

        it 'lists data' do
          expected = ['username', { prompt: 'Username', value: 'a_user' }]
          expect(subject.first).to match expected
        end
      end

      describe 'links' do
        subject { User.new(username: username).links }
        let(:username) { 'a_user' }

        it 'is empty' do
          expect(subject).to match []
        end
      end

      describe 'href' do
        subject { User.new(username: username).href }
        let(:username) { 'a_user' }

        it 'makes a url path for the user' do
          expect(subject).to eq "users/#{username}"
        end
      end

      describe 'identifier' do
        subject { User.new(username: username) }
        let(:username) { 'a_user' }

        it 'is the same as the uuid' do
          expect(subject.identifier).to eq subject.username
        end
      end
    end
  end
end
