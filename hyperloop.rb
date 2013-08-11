require 'socket'
require 'debugger'

class Hyperloop
  def initialize port
    @server = TCPServer.new port
  end

  def start
    loop do
      @socket = @server.accept
      read_data_from_socket
      send_response
      close_socket
    end
  end

  def read_data_from_socket
    data = @socket.readpartial 1024
    puts data
  end

  def send_response
    @socket.write "HTTP/1.1 200 OK\r\n"
    @socket.write "\r\n"
    @socket.write "w00t\n"
  end

  def close_socket
    @socket.close
  end
end

server = Hyperloop.new 3000
server.start