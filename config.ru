require 'webmachine/adapter'
require 'webmachine/adapters/rack'
require File.join(File.dirname(__FILE__), 'app')

Reviews.instance.database = 'collection-data-works'

run App.adapter
