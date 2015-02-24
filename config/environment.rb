app_config = File.join(File.dirname(__FILE__), "environments/#{RACK_ENV}.rb")

if File.file?(app_config)
  require app_config
else
  raise RuntimeError, "Missing configuration #{app_config}"
end
