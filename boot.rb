env_config = File.expand_path('config/environments/development.rb', File.dirname(__FILE__))
app_config = File.expand_path('config/environments/default.rb', File.dirname(__FILE__))

if File.file?(env_config)
  require env_config
else
  require app_config
end

require_relative 'app'

App.run
