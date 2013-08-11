class App
  def call(env)
    if env['PATH_INFO'] == '/'
      [200, { 'Content-Type' => 'text/html' }, ["Hello from the rack application inside config.ru with PID: #{Process.pid}\n"]]
    else
      [404, { 'Content-Type' => 'text/html' }, ['Boo.']]
    end
  end
end

run App.new