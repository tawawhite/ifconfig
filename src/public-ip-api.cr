
require "http/server"
require "json"
require "ipaddress"

server = HTTP::Server.new([
  HTTP::ErrorHandler.new,
  HTTP::CompressHandler.new,
]) do |context|
    if context.request.headers.has_key?("x-forwarded-for")
        begin
            ip = IPAddress.new context.request.headers["x-forwarded-for"].split(',')[0]
            output = {"ip" => ip.address}
            context.response.content_type = "application/json"
            context.response.print output.to_json
        rescue ArgumentError
            context.response.status_code = 404
            context.response.print "Invalid IP address"
        end
    else
        context.response.status_code = 404
        context.response.print "No IP address found"
    end
end

port = ENV["PORT"] ||= "5000"
puts "Listening on port #{port}"
server.listen("0.0.0.0", port.to_i, reuse_port: true)
