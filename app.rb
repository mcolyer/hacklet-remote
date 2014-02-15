require 'builder'
require 'rack/rpc'
require 'yaml'
require 'json'

Dir.glob(File.dirname(__FILE__) + '/plugins/*.rb') do |f|
  require f
end

class Server < Rack::RPC::Server
  # Public: Necessary for authentication purposes.
  #
  # Returns just the getRecentPosts action.
  def supported_methods(arg1)
    'metaWeblog.getRecentPosts'
  end
  rpc 'mt.supportedMethods' => :supported_methods

  # Public: Fetches the most recent posts.
  #
  # Return nothing so we never trigger ifttt.com.
  def recent_posts(blog_id, username, password, number_of_posts)
    '<array><data></data></array>'
  end
  rpc 'metaWeblog.getRecentPosts' => :recent_posts

  # Public: Executes the proper hacklet command based on the request.
  #
  # blog_id   - Used to differentiate blogs.
  # user      - The name of the user for authentication purposes
  # password  - The password for authentication purposes
  # publish   - Boolean to determine if it should be pending or published.
  # content
  #  ['title']       - 'on' or 'off' depending on which action is desired.
  #  ['description'] - The json payload for options.
  #
  # Returns '<string>200</string>' on success.
  def new_post(blog_id, user, password, content, publish)
    body = content['description']
    attributes = []

    return unauthorized unless valid_user_and_password?(user, password)
    begin; attributes = JSON.parse(body); rescue JSON::ParserError; end

    attributes.each do |arguments|
      plugin_name = Plugins.constants.find do |c|
        klass = Plugins.const_get(c)
        name = "Plugins::#{arguments['device'].capitalize}"
        Class === klass && klass.name == name
      end
      return bad_request unless plugin_name

      instance = Plugins.const_get(plugin_name).new(arguments)
      return bad_request unless instance.execute
    end

    return success
  end
  rpc 'metaWeblog.newPost' => :new_post

protected
  # Protected: Validates the user and password match the configuration.
  #
  # Returns true if they match and false otherwise.
  # Raises RuntimeError if the password hasn't been changed.
  def valid_user_and_password?(user, password)
    raise "Default password used, update config.yml" if configuration['password'] == 'default'
    configuration['user'] == user && configuration['password'] == password
  end

  # Protected: Fetches the configuration hash from config.yml in the local
  # directory.
  #
  # Returns the hash of attributes set in the configuration file.
  def configuration
    return @configuration if @configuration

    configuration_path = File.join(File.dirname(__FILE__), 'config.yml')
    @configuration = YAML.load_file(configuration_path)
  end

  # Helper: Returns the HTTP Unauthorized status code.
  def unauthorized
    403
  end

  # Helper: Returns the HTTP Bad Request status code.
  def bad_request
    400
  end

  # Helper: Returns the HTTP Success status code.
  def success
    200
  end
end
