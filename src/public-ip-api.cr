require "json"
require "ipaddress"
require "kemal"

Kemal.config.env = "production"
serve_static false

error 404 do
  ""
end

def get_ip(env)
  if env.request.headers.has_key?("x-forwarded-for")
    begin
      env.response.headers.add("Access-Control-Allow-Origin", "*")
      if env.request.path == "/"
        env.response.content_type = "text/plain"
        (IPAddress.new env.request.headers["x-forwarded-for"].split(',')[0]).address
        puts env.request.headers["x-forwarded-for"]
      elsif env.request.path == "/json"
        env.response.content_type = "application/json"
        {"ip" => (IPAddress.new env.request.headers["x-forwarded-for"].split(',')[0]).address}.to_json
        puts env.request.headers["x-forwarded-for"]
      end
    rescue ArgumentError
      env.response.status_code = 404
      env.response.print "Invalid IP address"
    end
  else
    env.response.status_code = 404
    env.response.print "No IP address found"
  end
end

get "/" do |env|
  get_ip(env)
end

get "/json" do |env|
  get_ip(env)
end

Kemal.run do |config|
  port = ENV["PORT"] ||= "5000"
  puts "Running on port #{port}"
  server = config.server.not_nil!
  server.bind_tcp "0.0.0.0", port.to_i, reuse_port: true
end
