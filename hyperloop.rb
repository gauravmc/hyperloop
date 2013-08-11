require 'socket'
require 'http/parser'

class Hyperloop
  def initialize port
    @server = TCPServer.new port
  end

  def start
    loop do
      socket = @server.accept
      SocketHandler.new(socket).process
    end
  end

  class SocketHandler
    def initialize socket
      @socket = socket
      @parser = Http::Parser.new self
    end

    def process
      parse_data_from_socket
    end

    def parse_data_from_socket
      data = @socket.readpartial 1024
      @parser << data
    end

    def on_message_complete
      send_response
      close_socket
      write_to_screen
    end

    def send_response
      @socket.write "HTTP/1.1 #{@parser.http_method} OK\r\n"
      @socket.write "\r\n"
      @socket.write "w00t\n"
    end

    def write_to_screen
      puts "#{@parser.http_method} #{@parser.request_path}"
      puts @parser.headers.inspect
      puts
    end

    def close_socket
      @socket.close
    end
  end
end

server = Hyperloop.new 3000
server.start