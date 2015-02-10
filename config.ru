require File.join(File.dirname(__FILE__), 'config/boot')
require 'rack/static'

run App.adapter
