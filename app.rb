require 'builder'
require 'rack/rpc'
require 'yaml'
require 'json'

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
    command = content['title']
    body = content['description']
    attributes = {}

    return unauthorized unless valid_user_and_password?(user, password)
    return bad_request unless ['on', 'off'].include? command

    begin; attributes = JSON.parse(body); rescue JSON::ParserError; end
    return bad_request unless socket = attributes['socket'].to_i
    return bad_request unless network = attributes['network'].to_i(16)

    command = "hacklet #{command} -n 0x#{network.to_s(16)} -s #{socket}"
    puts "Executing: '#{command}'"
    begin; puts `#{command}`; rescue; end

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
