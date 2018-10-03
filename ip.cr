
require "http/server"
require "json"

server = HTTP::Server.new do |context|
    if context.request.headers.has_key?("x-forwarded-for")
        ip = {"ip" => context.request.headers["x-forwarded-for"].split(',')[0]}
        context.response.content_type = "application/json"
        context.response.print ip.to_json
    else
        context.response.status_code = 404
        context.response.print "No IP address found"
    end
end

puts "Listening on port 5000"
server.listen("0.0.0.0", 5000, reuse_port: true)
