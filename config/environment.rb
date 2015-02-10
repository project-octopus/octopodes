app_config = File.join(File.dirname(__FILE__), "environments/#{RACK_ENV}.rb")
def_config = File.join(File.dirname(__FILE__), 'environments/default.rb')

if File.file?(app_config)
  require app_config
else
  require def_config
end
