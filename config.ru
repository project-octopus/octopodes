require File.join(File.dirname(__FILE__), 'config/boot')
require 'rack/static'

use Rack::Static, :urls => ["/favicon.ico", "/assets", "/docs"],
                  :root => "public"

run App.adapter
