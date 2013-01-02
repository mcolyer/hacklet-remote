require './app'

# config.ru
use Log
use Rack::RPC::Endpoint, Server.new, :path => "/xmlrpc.php"

app = proc do |env|
  [ 200, {'Content-Type' => 'text/plain'}, ["a"] ]
end

run app
