# Database

Install PostgreSQL:

Debian/Ubuntu:

    sudo apt-get install postgresql postgresql-contrib libpq-dev

On Mac OS X (using homebrew):

    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew install postgresql

## User Role

Switch to the postgres account:

    sudo -i -u postgres

Login to the Postgres prompt:

    psql

Create a user role with `createdb` privilege:

    create role octopus with login password 'password';

## Database

Create the database:

    CREATE DATABASE octopodes WITH ENCODING 'UTF-8';
    GRANT ALL ON DATABASE octopodes TO octopus;

## Auditing

Log in to the `psql` console as the postgres admin user. Then connect to your database:

    \c octopodes

Import the audit file:

    \i /path/to/octopodes/db/triggers/audit.sql

Let the user read the audit history:

    GRANT USAGE ON SCHEMA audit TO octopus;
    GRANT SELECT ON ALL TABLES IN SCHEMA audit TO octopus;

Update your database configuration file:

    configatron.sequel.audit = true
