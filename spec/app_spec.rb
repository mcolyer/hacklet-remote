require 'spec_helper'

describe Server do
  def app
    base = proc do |env|
      [ 200, {'Content-Type' => 'text/plain'}, ['hacklet'] ]
    end
    Rack::RPC::Endpoint.new(base, subject, :path => '/xmlrpc.php')
  end

  def build_request(user, password, command)
    <<-END
      <?xml version="1.0"?>
      <methodCall>
        <methodName>metaWeblog.newPost</methodName>
        <params>
          <param><value> <string/> </value></param>
          <param><value> <string>#{user}</string> </value></param>
          <param><value> <string>#{password}</string> </value></param>
          <param><value> <struct>
            <member> <name>title</name> <value> <string></string> </value></member>
            <member> <name>description</name> <value> <string>[{"device":"socket", "command": "#{command}", "network": "0xc6d2", "socket":0}]</string> </value></member>
            <member> <name>post_status</name> <value> <string>publish</string> </value></member>
          </struct> </value> </param>
          <param> <value> <boolean>1</boolean> </value> </param>
        </params>
      </methodCall>
    END
  end

  def response(status)
    "<?xml version=\"1.0\" ?><methodResponse><params><param><value><i4>#{status}</i4></value></param></params></methodResponse>\n"
  end

  def xmlrpc_request(body)
    post '/xmlrpc.php', {}, {'rack.input' => StringIO.new(body), 'CONTENT_TYPE' => 'text/xml'}
  end

  describe 'the default location' do
    before do
      get '/'
    end

    it 'is successful' do
      last_response.should be_ok
    end

    it 'has a helpful message' do
      last_response.body.should eq('hacklet')
    end
  end

  describe 'controlling the hacklet' do
    context 'with an invalid' do
      before do
        subject.stub(:configuration).and_return({ 'user' => 'b', 'password' => 'b' })
      end

      context 'username' do
        let(:body) { build_request('a', 'b', 'on') }

        before do
          xmlrpc_request(body)
        end

        it 'fails' do
          last_response.body.should eq(response(403))
        end
      end

      context 'password' do
        let(:body) { build_request('b', 'a', 'on') }

        before do
          xmlrpc_request(body)
        end

        it 'fails' do
          last_response.body.should eq(response(403))
        end
      end
    end

    context 'with a valid credentials' do
      before do
        subject.stub(:configuration).and_return({ 'user' => 'user', 'password' => 'password' })
      end

      describe 'turning on' do
        let(:body) { build_request('user', 'password', 'on') }

        before do
          Plugins::Socket.any_instance.should_receive(:`).with('hacklet on -n 0xc6d2 -s 0').and_return('None')
          xmlrpc_request(body)
        end

        it 'succeeds' do
          last_response.body.should eq(response(200))
        end
      end

      describe 'turning off' do
        let(:body) { build_request('user', 'password', 'off') }

        before do
          Plugins::Socket.any_instance.should_receive(:`).with('hacklet off -n 0xc6d2 -s 0').and_return('None')
          xmlrpc_request(body)
        end

        it 'succeeds' do
          last_response.body.should eq(response(200))
        end
      end
    end
  end

end
