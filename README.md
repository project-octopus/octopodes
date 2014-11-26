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

Run the test suite:

    bundle exec rspec

***Note:*** Running tests will re-create the database and delete it when the tests are over.

Consult the next section on how to configure a database just for testing.

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

Edit `test.rb` and change your database details. then run the tests:

    bundle exec rspec

## Documentation

[Read the Documentation](doc/api/index.markdown)

Documentation is generated with the following task:

    bundle exec rake docs:generate

## Credits

Octopus by Jason Grube from The Noun Project
