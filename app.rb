require 'builder'
require 'rack/rpc'
require 'yaml'
require 'json'

class Server < Rack::RPC::Server
  def supported_methods(arg1)
    # Give an endpoint for authentication purposes
    'metaWeblog.getRecentPosts'
  end
  rpc 'mt.supportedMethods' => :supported_methods

  def recent_posts(blog_id, username, password, number_of_posts)
    # Return nothing so we never trigger
    '<array><data></data></array>'
  end
  rpc 'metaWeblog.getRecentPosts' => :recent_posts

  # Public: Executes the proper hacklet command based on the request.
  #
  # user - The name of the user for authentication purposes
  # password - The password for authentication purposes
  # content['title'] - 'on' or 'off' depending on which action is desired.
  # content['description'] - The json payload for options.
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
  def valid_user_and_password?(user, password)
    raise "Default password used, update config.yml" if configuration['password'] == 'default'
    configuration['user'] == user && configuration['password'] == password
  end

  def configuration
    return @configuration if @configuration

    configuration_path = File.join(File.dirname(__FILE__), 'config.yml')
    @configuration = YAML.load_file(configuration_path)
  end

  def unauthorized
    403
  end

  def bad_request
    400
  end

  def success
    200
  end
end
