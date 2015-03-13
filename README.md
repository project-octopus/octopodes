![Octopus](/public/assets/octopus.png?raw=true)

## About

A prototype hypermedia API for recording the use of creative works and media objects on the World Wide Web.

## Requirements

* Ruby 1.9.3 or 2.0+
* Bundler (`gem install bundler`)
* PostgreSQL 9.0+

PostgreSQL needs to be installed with headers and dev packages. On Ubuntu/Debian this can be done by:

    sudo apt-get install postgresql postgresql-contrib libpq-dev

## Installation

Grab a copy of the code:

    git clone git@github.com:project-octopus/octopodes.git && cd octopodes

Install the needed Ruby gems using Bundler:

    bundle install

## Set Up

### Database

#### Configuration File

Make a copy of the config file

  cp config/environments/sample.rb config/environments/development.rb

Fill in `development.rb` with your database credentials.

#### User, database, audit log

Create a user role and database in PostgreSQL.

**Note**: If you want to track database history, you need to import the `triggers/audit.sql` file into your database as the postgres admin user, and grant `USAGE` and `SELECT` privileges on the `audit` schema to the database user you've created. Then in your config file set `configatron.sequel.audit` to `true`.

Consult the `db/README.md` file for specific instructions.

#### Migrations

Run the migration task:

    bundle exec rake db:migrate

### Assets

Compile the stylesheets:

    bundle exec compass compile

## Updating

If you want to update your code: first pull any changes and install new gems, then re-run the migration and asset compilation tasks:

    git pull origin master
    bundle install
    bundle exec rake db:migrate
    bundle exec compass compile

## Usage

To run locally:

    bundle exec rackup -p 8080 -o 0.0.0.0

The site will be available at `http://localhost:8080`

## Testing

To run the automated testing suite, create a new PostgreSQL database just for testing.

Make a copy of the config file

    cp config/environments/sample.rb config/environments/test.rb

Fill in `test.rb` with the testing database credentials and run the migrations:

    bundle exec rake db:migrate RACK_ENV=test

Finally, run the test suite:

    bundle exec rspec

## Deploying

Put production settings in `config/environments/production.rb` and create your database:

    bundle exec rake db:migrate RACK_ENV=production

The project has a `config.ru` file that works with Phusion Passenger.

In your virtual host file you must specify `RackEnv production`.

In addition, compile the stylesheets for a production environment:

    bundle exec compass compile --output-style compressed --force

## Documentation

[Read the API Documentation](http://project-octopus.org/docs/api/index.html)

Documentation is generated with the following task:

    bundle exec rake docs:generate

## Security

The software supports Basic Authentication only and signed session cookies.

Passwords are stored using the bcrypt hash algorithm.
