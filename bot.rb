require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'


### Substitute values for YOUR_BOT_NAME and YOUR_SERVER_NAME
class Google
  include Cinch::Plugin
  match /google (.+)/

  def search(query)
    url = "http://www.google.com/search?q=#{CGI.escape(query)}"
    res = Nokogiri::HTML(open(url)).at("h3.r")

    title = res.text
    # link = res.at('a')[:href]
    link = res.at("./following::div/cite").text

    CGI.unescape_html "#{title} - http://#{link}"
  rescue
    "No results found"
  end

  def execute(m, query)
    m.reply(search(query))
  end
end

class UrbanDictionary
  include Cinch::Plugin
  match /ud (.+)/

  def search(query)
    url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(query)}"
    result = Nokogiri::HTML(open(url)).at(".meaning")
    meaning = result.text

    CGI.unescape_html "#{meaning}"
  rescue
    "No results found"
  end

  def execute(m, query)
    m.reply(search(query))
  end
end

class DoMath
  include Cinch::Plugin
  match /calc (.+)/

  def calc(query)
    total = eval(query)
    total
  rescue
    "Please check your format"
  end

  def execute(m, query)
    m.reply(calc(query))
  end
end
 
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

# class Bookmark
#   include Cinch::Plugin
#   match /bookmark (.+)/

#   def bookmark(query)
#     mark = query()
#     content = query.gsub(/(bookmark\s)/, '')
#   end
# end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "neonbot2"
    c.server = "dickson.freenode.net"
    c.channels = ["#femalefashionadvice"]
    c.plugins.plugins = [Google, DoMath, UrbanDictionary, Wolframsearch]
  end

  on :message, "hi" do |m|
    m.reply "Hello, #{m.user.nick}."
  end

  on :message, "die" do |m|
    m.reply "I hate everything too, #{m.user.nick}."
  end

  on :action, "kicks the bot" do |m|
    m.reply "Ouch! Stop kicking me :(", true
  end

  on :action, "whacks the bot with a wet trout" do |m|
    m.action_reply "whacks #{m.user.nick} back with a whale"
  end

  on :message, "ping" do |m|
    m.reply "pong"
  end

  on :action, "hugs the bot" do |m|
    m.action_reply "blushes and hugs #{m.user.nick} back"
  end

  on :message, /\b(alot)\b/i do |m|
    m.reply "http://i.imgur.com/6dmTfHT.png"
  end

end

bot.start
