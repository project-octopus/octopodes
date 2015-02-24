require 'spec_helper'
require 'octopodes/repositories/user'
require 'octopodes/domain/user'

include Octopodes::Domain

module Octopodes
  # Test for User Repository
  module Repositories
    describe User do
      describe 'token' do
        subject { Repositories::User.token }

        it 'generates a UUID' do
          uuid_regex = /([a-f\d]{8}(-[a-f\d]{4}){3}-[a-f\d]{12}?)/i
          expect(subject).to match uuid_regex
        end
      end

      describe 'new' do
        subject { Repositories::User.new }

        context 'with no arguments' do
          it 'returns a new user' do
            expect(subject).to be_a(Domain::User)
          end
        end
      end

      describe 'create' do
        subject { Repositories::User.create(token, data) }

        context 'with valid data' do
          let(:token) { 'd53b184a-346a-41ae-8687-438f4e81cf13' }
          let(:data) { { 'username' => 'a_user', 'password' => 'a_pass' } }

          it 'creates and returns a user' do
            expect(subject.valid?).to be true
            expect(subject.token).to eq token
            expect(subject.username).to eq data['username']
          end
        end

        context 'with invalid data' do
          let(:token) { 'd53b184a-346a-41ae-8687-438f4e81cf13' }
          let(:data) { { 'username' => '', 'password' =>  '' } }

          it 'returns a work with errors' do
            expect(subject.valid?).to be false
          end
        end
      end

      describe 'update' do
        subject { Repositories::User.update(username, token, data) }

        context 'with new password' do
          let(:username) { 'user1' }
          let(:data) { { 'password' => 'new' } }
          let(:token) { Repositories::User.token }

          it 'updates and returns a user' do
            load(:users)
            expect(subject.valid?).to be true
            expect(subject.token).to eq token
            expect(subject.authenticate('new')).to be subject
          end
        end

        context 'without a new password' do
          let(:username) { 'user1' }
          let(:data) { { 'password' => '' } }
          let(:token) { Repositories::User.token }

          it 'returns the user with unchanged password' do
            load(:user__user1)
            expect(subject.valid?).to be true
            expect(subject.token).to eq token
            expect(subject.authenticate('pass1')).to be subject
          end
        end
      end

      describe 'list' do
        subject { Repositories::User.list(options) }

        context 'with no options' do
          let(:options) { {} }

          it 'returns all users' do
            load(:users)
            expect(subject.count).to eq 2
          end

          it 'returns users alphabetically by username' do
            load(:users)
            expect(subject.first.id).to eq 1
            expect(subject.last.id).to eq 2
          end
        end

        context 'with limit 1' do
          let(:options) { { limit: 1 } }

          it 'returns 1 user' do
            load(:users)
            expect(subject.count).to eq 1
          end
        end

        context 'with startkey' do
          let(:options) { { startkey: startkey } }
          let(:startkey) { 'UNUSED_CREATED_wT_KEY,user1' }

          it 'returns users starting from the key' do
            load(:users)
            expect(subject.count).to eq 1
            expect(subject.first.id).to eq 2
          end
        end
      end

      describe 'find' do
        subject { Repositories::User.find(username) }

        context 'with an existing record' do
          let(:username) { 'user1' }

          it 'returns a user' do
            load(:user__user1)
            expect(subject.first.username).to eq 'user1'
            expect(subject.first.email).to eq 'user1@example.org'
          end
        end

        context 'with a non-existant record' do
          let(:username) { 'user_x' }

          it 'returns nil' do
            load(:user__user1)
            expect(subject).to eq []
          end
        end
      end

      describe 'identify' do
        subject { Repositories::User.identify(token) }

        context 'with a user having the token' do
          let(:token) { 'e2436dc4-291c-4c84-b0f9-7f7c980123de' }

          it 'returns a user' do
            load(:user__user1)
            expect(subject.username).to eq 'user1'
            expect(subject.email).to eq 'user1@example.org'
          end
        end
      end

      describe 'authenticate' do
        subject { Repositories::User.authenticate(username, password) }

        context 'with correct credentials' do
          let(:username) { 'user1' }
          let(:password) { 'pass1' }

          it 'returns a user' do
            load(:user__user1)
            expect(subject.username).to eq 'user1'
          end
        end

        context 'with incorrect credentials' do
          let(:username) { 'user1' }
          let(:password) { 'xxxx' }

          it 'returns nil' do
            load(:user__user1)
            expect(subject).to eq nil
          end
        end

        context 'with nonexistent user' do
          let(:username) { 'xxxx' }
          let(:password) { 'xxxx' }

          it 'returns nil' do
            load(:user__user1)
            expect(subject).to eq nil
          end
        end
      end

      describe 'count' do
        subject { Repositories::User.count }

        it 'returns the number of users' do
          load(:users)
          expect(subject).to eq 2
        end
      end
    end
  end
end
