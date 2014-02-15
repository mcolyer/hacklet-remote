module Plugins
  class Socket
    def initialize (arguments)
      @arguments = arguments
    end

    def execute
      command = @arguments['command']
      return false unless ['on', 'off'].include? command
      return false unless socket = @arguments['socket'].to_i
      return false unless network = @arguments['network'].to_i(16)

      command = "hacklet #{command} -n 0x#{network.to_s(16)} -s #{socket}"
      puts "Executing: '#{command}'"
      begin; puts `#{command}`; rescue; end

      true
    end
  end
end
