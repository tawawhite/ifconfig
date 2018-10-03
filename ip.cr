
require "http/server"
require "json"
require "ipaddress"

server = HTTP::Server.new do |context|
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

puts "Listening on port 5000"
server.listen("0.0.0.0", 5000, reuse_port: true)
