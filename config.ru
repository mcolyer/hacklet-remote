require './app'

use Rack::CommonLogger
use Rack::RPC::Endpoint, Server.new, :path => '/xmlrpc.php'

app = proc do |env|
  [ 200, {'Content-Type' => 'text/plain'}, ['hacklet'] ]
end

run app
