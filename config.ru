require './app'

module Rack
  class Snoop
    def initialize(app)
      @app = app
    end

    def call(env)
      puts env.inspect
      status, headers, body = @app.call(env)
      [status, headers, body]
    end
  end
end

use Rack::Snoop
use Rack::CommonLogger
use Rack::RPC::Endpoint, Server.new, :path => '/xmlrpc.php'

app = proc do |env|
  [ 200, {'Content-Type' => 'text/plain'}, ['hacklet'] ]
end

run app
