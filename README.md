![Octopus](/public/assets/octopus.png?raw=true)

## About

A prototype hypermedia API for recording the use of creative works and media objects on the World Wide Web.

## Requirements

* Ruby
* Bundler
* CouchDB
* rake
* libmagic

## Installation

You need to install the above requirements using the package manager for your operating system. You probably already have Ruby (>= 1.9.3) but the rest you will need to download.

Next, install the needed Ruby gems using Bundler:

    bundle install

## Set Up

Run rake to set up the database

    rake octopus:db:create

Your database will be created at `http://localhost:5984/project-octopus`

## Usage

To run locally:

    bundle exec ruby boot.rb

The site will be available at `http://localhost:8080`

## Testing

Add test data to the database:

    rake octopus:db:fixtures

Then run the test suite:

    bundle exec rspec

## Custom database

You can configure your database locations for testing or development.

### Development

To customize the database used by the running app:

    cp config/environments/default.rb config/environments/development.rb

Edit `development.rb` and change your database details. Then set up the database and run the app:

    rake octopus:db:create[development]
    bundle exec ruby boot.rb

### Testing

To customize the database used by the tests:

    cp config/environments/default.rb config/environments/test.rb

Edit `test.rb`, then set up the database and run the tests:

    rake octopus:db:create[test]
    rake octopus:db:fixtures[test]
    bundle exec rspec

When you are finished you can delete the test database:

    rake octopus:db:delete[test]

## Documentation

[Read the Documentation](doc/api/index.markdown)

Documentation is generated with the following task:

    bundle exec rake docs:generate

## Credits

Octopus by Jason Grube from The Noun Project
