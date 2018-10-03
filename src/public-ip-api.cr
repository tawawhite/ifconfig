require "json"
require "ipaddress"
require "kemal"

Kemal.config.env = "production"
serve_static false
logging false

error 404 do
  ""
end

get "/" do |env|
  if env.request.headers.has_key?("x-forwarded-for")
    begin
      env.response.content_type = "text/plain"
      env.response.headers.add("Access-Control-Allow-Origin", "*")
      (IPAddress.new env.request.headers["x-forwarded-for"].split(',')[0]).address
    rescue ArgumentError
      env.response.status_code = 404
      env.response.print "Invalid IP address"
    end
  else
    env.response.status_code = 404
    env.response.print "No IP address found"
  end
end

get "/json" do |env|
    if env.request.headers.has_key?("x-forwarded-for")
      begin
        env.response.content_type = "application/json"
        env.response.headers.add("Access-Control-Allow-Origin", "*")
        {"ip" => (IPAddress.new env.request.headers["x-forwarded-for"].split(',')[0]).address}.to_json
      rescue ArgumentError
        env.response.status_code = 404
        env.response.print "Invalid IP address"
      end
    else
      env.response.status_code = 404
      env.response.print "No IP address found"
    end
  end

Kemal.run do |config|
  port = ENV["PORT"] ||= "5000"
  puts "Running on port #{port}"
  server = config.server.not_nil!
  server.bind_tcp "0.0.0.0", port.to_i, reuse_port: true
end
