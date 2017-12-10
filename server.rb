require "socket"

def parse_request(request_line)
  http_method, path_and_params, http = request_line.split(" ")
  path, params = path_and_params.split("?")
  params = (params || "").split("&").each_with_object({}) do |pair, hash|
    key, value = pair.split("=")
    hash[key] = value
  end

  [http_method, path, params]
end

server = TCPServer.new("localhost", 3003)
loop do
  client = server.accept
  request_line = client.gets
  next if !request_line || request_line =~ /favicon/ || request_line =~ /robots/
  puts request_line

  next unless request_line # dealing with empty requests

  http_method, path, params = parse_request(request_line)

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html\r\n\r\n"
  client.puts "<html>"
  client.puts "<body>"
  client.puts "<pre>"
  client.puts request_line
  client.puts http_method
  client.puts path
  client.puts params
  client.puts "</pre>"

# => Dice rolling code
#  client.puts "<h1>Rolls!</h1>"

#  rolls = params["rolls"].to_i
#  sides = params["sides"].to_i
#  rolls.times do
#    roll = rand(sides) + 1
#    client.puts "<p>", roll, "</p>"
#  end

  client.puts "<h1>Counter</h1>"

  number = params["number"].to_i # to_i on nil returns 0

  client.puts "<p>The current number is #{number}.</p>"

  client.puts "<a href='?number=#{number + 1}'>Add one</a>"
  client.puts "<a href='?number=#{number - 1}'>Subtract one</a>"

  client.puts "</body>"
  client.puts "</html>"

  client.close
end
