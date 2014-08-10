#require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'wolfram-alpha'
require 'cgi'

#export WOLFRAM_APPID='855858-G8QRY7HHWQ'
options = { "format" => "plaintext" } # see the reference appendix in the documentation.[1]w
client = WolframAlpha::Client.new "855858-G8QRY7HHWQ", options
#Wolfram.appid = "855858-G8QRY7HHWQ"

query = "prius"
response = client.query(query)

input = response["Input"] # Get the input interpretation pod.
#result = response.find { |pod| pod.title == "Result" } # Get the result pod.
results = response.find{ |pod| pod.title == "Results"}

#result = result.subpods[0].plaintext
#puts result
#puts "#{result.subpods[0].plaintext}"
puts "#{results.subpods[0].plaintext}"


