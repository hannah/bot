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

=begin
class DoMath
  include Cinch::Plugin
  match /calc (.+)/

  def calc(query)
    message = query[5..-1]
    total = eval(message)
    return total
  rescue
    "Please check your format"
  end

  def execute(m, query)
    m.reply(calc(query))
  end
end
=end

class Bookmark
  include Cinch::Plugin
  match /bookmark (.+)/

  def bookmark(query)
    mark = query()
    content = query.gsub(/(bookmark\s)/, '')
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "nothubot"
    c.server = "sendak.freenode.net"
    c.channels = ["#cinch-bots"]
    c.plugins.plugins = [Google]
    #c.plugins.plugins = [Wolfram]
  end


  on :message, "hello" do |m|
    m.reply "Hello, #{m.user.nick}."
  end

  on :message, "die" do |m|
    m.reply "I hate Hubot too, #{m.user.nick}."
  end

  on :action, "kicks the bot" do |m|
    m.reply "Ouch! Stop kicking me :(", true
  end

end

bot.start
