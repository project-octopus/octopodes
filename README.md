![Octopus](/vendor/assets/icon_15331/icon_15331_small.png?raw=true)

## About

A prototype hypermedia API for recording the use of creative works and media objects on the World Wide Web.

## Requirements

* Ruby
* Bundler
* CouchDB
* curl

## Set Up

Install the needed Ruby gems

    bundle install

Run the set-up script to create your database:

    ./setup.sh

## Usage

To run locally:

    bundle exec ruby boot.rb

The site will be available at `http://localhost:8080/reviews/`

## Testing

Run the set-up script to create the test database

    ./setup_test.sh

Run the command:

    bundle exec rspec

## Credits

Octopus by Jason Grube from The Noun Project
