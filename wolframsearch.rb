require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'wolfram-alpha'
require 'cgi'

 
class Wolframsearch
  include Cinch::Plugin
  #plugin "wolfram"
 
  match /wa (.+)/
 
  def self.search(query)
    url = "http://www.wolframalpha.com/input/?i=#{CGI.escape(query)}"
    
    # Get API key from
    #          https://developer.wolframalpha.com/portal/signin.html
    options = { "format" => "plaintext" } # see the reference appendix in the documentation.[1]w
    client = WolframAlpha::Client.new "855858-G8QRY7HHWQ", options
 
    query = client.query(query)
    #if query.result
      result = query.find { |pod| pod.title == "Result" } # Get the result pod
      result = result.subpods[0].plaintext
    #else
     #"Sorry, I've no idea"
    #end
  rescue
    url
  end
 
  def execute(m, query)
    m.reply self.class.search(query), true #self.class.search
  end
end