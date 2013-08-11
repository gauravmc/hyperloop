require 'socket'
require 'http/parser'
require 'stringio'

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
end

class Hyperloop
  module AppLoader
    def run app
      app
    end

    def load_app
      eval File.read('config.ru')
    end
  end
end

class Hyperloop
  class SocketHandler
    include Hyperloop::AppLoader

    def initialize socket
      @socket = socket
      @parser = Http::Parser.new self
      @app = load_app
    end

    def process
      parse_data_from_socket
    end

    def parse_data_from_socket
      until @socket.closed? || @socket.eof?
        data = @socket.readpartial 1024
        @parser << data
      end
    end

    def on_message_complete
      send_response
      close_socket
      write_to_screen
    end

    def send_response
      status, headers, body = @app.call parsed_data_to_rack_env
      @socket.write "HTTP/1.1 #{status} OK\r\n"

      headers.each_pair { |key, value| @socket.write "#{key}: #{value}\r\n" }
      @socket.write "\r\n"
      body.each { |chunk| @socket.write chunk }
      body.close if body.respond_to? :close
    end

    def parsed_data_to_rack_env
      Hash.new.tap do |env|
        @parser.headers.each_pair do |key, value|
          env["HTTP_#{key.upcase.gsub('-', '_')}"] = value
        end
        env['PATH_INFO'] = @parser.request_path
        env["REQUEST_METHOD"] = @parser.http_method
        env["rack.input"] = StringIO.new
      end
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
puts "Starting Hyperloop server on port 3000"
server.start
