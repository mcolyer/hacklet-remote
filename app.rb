require "sinatra/base"
require "yaml"

Dir.glob(File.dirname(__FILE__) + "/plugins/*.rb") do |f|
  require f
end

class App < Sinatra::Base
  post "/" do
    return 403 unless valid_key?(params["key"])
    attributes = []

    begin
      attributes = JSON.parse(request.body.read)
    rescue JSON::ParserError; end

    attributes.each do |arguments|
      plugin_name = Plugins.constants.find do |c|
        klass = Plugins.const_get(c)
        name = "Plugins::#{arguments["device"].capitalize}"
        Class === klass && klass.name == name
      end
      return 400 unless plugin_name

      instance = Plugins.const_get(plugin_name).new(arguments)
      return 400 unless instance.execute
    end

    return 200
  end

protected
  # Protected: Validates the user and password match the configuration.
  #
  # Returns true if they match and false otherwise.
  # Raises RuntimeError if the password hasn"t been changed.
  def valid_key?(key)
    raise "Default key used, update config.yml" if configuration["key"] == "default"
    configuration["key"] == key
  end

  # Protected: Fetches the configuration hash from config.yml in the local
  # directory.
  #
  # Returns the hash of attributes set in the configuration file.
  def configuration
    return @configuration if @configuration

    configuration_path = File.join(File.dirname(__FILE__), "config.yml")
    @configuration = YAML.load_file(configuration_path)
  end
end
