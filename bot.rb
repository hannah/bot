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

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "YOUR_BOT_NAME"
    c.server = "YOUR_SERVER_NAME"
    c.channels = ["#cinch-bots"]
    c.plugins.plugins = [Google]
    # c.plugins.plugins = [DoMath]
  end

  on :message, "hello" do |m|
    m.reply "Hello, #{m.user.nick}."
  end

  on :message, "die" do |m|
    m.reply "I hate Hubot too, #{m.user.nick}."
  end
end

bot.start
