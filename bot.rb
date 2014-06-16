require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'wolfram-alpha'
require 'yaml'



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

class Memo
  include Cinch::Plugin

  def initialize(*args)
    super
    if File.exist?('memos.yaml')
      @memos = YAML.load_file('memos.yaml')
    else
      @memos = {}
    end
  end

  #plugin "memo"
  #help "!memo <name> <message> - Leave memos for other users"

  listen_to :message
  match /note (.+?) (.+)/

  def listen(m)
    if @memos.key?(m.user.nick) and @memos[m.user.nick].size > 0
      while @memos[m.user.nick].size > 0
        msg = @memos[m.user.nick].shift
        m.reply "#{m.user.nick}" + msg
      end
      @memos.delete m.user.nick
      update_store
    end
  end

  def execute(m, nick, message)
    if nick == m.user.nick
      m.reply "You can't leave memos for yourself..."
    elsif nick == bot.nick
      m.reply "You can't leave memos for me..."
    elsif @memos.key?(nick)
      msg = make_msg(m.user.nick, message, Time.now)
      @memos[nick] << msg
      m.reply "Added note for #{nick}"
      update_store
    else
      @memos[nick] ||= []
      msg = make_msg(m.user.nick, message, Time.now)
      @memos[nick] << msg
      m.reply "Added note for #{nick}"
      update_store
    end
  end

  def update_store
    synchronize(:update) do
      File.open('memos.yaml', 'w') do |fh|
        YAML.dump(@memos, fh)
      end
    end
  end

  def make_msg(nick, text, time)
    t = time.strftime("%Y-%m-%d")
    #{}"<#{nick}/#{t}> #{text}"
    ":Note from #{nick} on #{t}: #{text}"
  end
end

class RandomCat
  include Cinch::Plugin
  match /cat/

  def cat_generator
    url = "http://thecatapi.com/api/images/get?format=src&type=gif"
    # result = Nokogiri::HTML(open(url)).at("body")
    returned_url = ""
  open(url) do |resp|
    returned_url = resp.base_uri.to_s
  end
  # rescue
  #   "No cat found."
  end

  def execute(m)
    m.reply(cat_generator)
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
    c.nick = "bestneonbot"
    c.server = "hobana.freenode.net"
    c.channels = ["#femalefashionadvice"]
    c.plugins.plugins = [Google, DoMath, UrbanDictionary, Wolframsearch, Memo, RandomCat]
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
