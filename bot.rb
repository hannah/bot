require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'wolfram-alpha'
require 'yaml'
require 'forecast_io'
require 'geocoder'
require 'net/http'
require 'uri'

# class Numeric

#   def fahrenheit_to_celsius
#     (self - 32) * 5 / 9
#   end

#   def celsius_to_fahrenheit
#     self * 9 / 5 + 32
#   end

# end


### Substitute values for YOUR_BOT_NAME and YOUR_SERVER_NAME
class Cat
  include Cinch::Plugin
  match /cat/

  def execute(m)
    response = Net::HTTP.get_response(URI('http://thecatapi.com/api/images/get?format=src&type=gif'))
    if response.is_a?(Net::HTTPSuccess)
      result = response.body
    else
      result = response['location']
      #puts response['location']
    end

    m.reply "Here is a cat #{result}"
  end
end

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
    meaning = result.text.split.slice(0, 30).join(" ")

    CGI.unescape_html "#{meaning}"
  rescue
    "No results found"
  end

  def execute(m, query)
    if query == 'noob'
      m.reply "a person who is inexperienced in a particular sphere or activity, especially computing or the use of the Internet. SEE ALSO: #{m.user.nick}."
    else
      m.reply(search(query))
    end
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
    if File.exist?('memos.yaml') #or File.exist?('privmemos.yaml')
      @memos = YAML.load_file('memos.yaml')
      #@privmemos = YAML.load_file('privmemos.yaml')
    else
      @memos = {}
      #@privmemos = {}
    end
  end

  #plugin "memo"
  #help "!memo <name> <message> - Leave memos for other users"

  listen_to :message
  match /note (.+?) (.+)/
  

  def listen(m)
    if @memos.key?(m.user.nick.downcase) and @memos[m.user.nick.downcase].size > 0
      while @memos[m.user.nick.downcase].size > 0
        msg = @memos[m.user.nick.downcase].shift
        m.reply "#{m.user.nick}" + msg
      end
      @memos.delete m.user.nick.downcase
      update_store
    end
    # if @privmemos.key?(m.user.nick) and @privmemos[m.user.nick].size > 0
    #   while @privmemos[m.user.nick].size > 0
    #     privmsg = @privmemos[m.user.nick].shift
    #     User(m.user.nick).send(privmsg)
    #   end
    #   @privmemos.delete m.user.nick
    #   update_store
    # end
  end

  def execute(m, nick, message)
    #if m.include?("note")
      if nick == m.user.nick
        m.reply "You can't leave memos for yourself..."
      elsif nick == bot.nick
        m.reply "You can't leave memos for me..."
      elsif @memos.key?(nick)
        msg = make_msg(m.user.nick.downcase, message, Time.now)
        @memos[nick.downcase] << msg
        m.reply "Added note for #{nick}"
        update_store
      else
        @memos[nick.downcase] ||= []
        msg = make_msg(m.user.nick.downcase, message, Time.now)
        @memos[nick.downcase] << msg
        m.reply "Added note for #{nick}"
        update_store
      end

    # else 
    #   if nick == m.user.nick
    #     m.reply "You can't leave memos for yourself..."
    #   elsif nick == bot.nick
    #     m.reply "You can't leave memos for me..."
    #   elsif @privmemos.key?(nick)
    #     msg = make_msg(m.user.nick, message, Time.now)
    #     @privmemos[nick] << msg
    #     m.reply "Added privnote for #{nick}"
    #     update_store
    #   else
    #     @privmemos[nick] ||= []
    #     msg = make_msg(m.user.nick, message, Time.now)
    #     @privmemos[nick] << msg
    #     m.reply "Added privnote for #{nick}"
    #     update_store
    #   end
     
  end

  def update_store
    synchronize(:update) do
      File.open('memos.yaml', 'w') do |fh|
        YAML.dump(@memos, fh)
      end
      # File.open('privmemos.yaml', 'w') do |fh|
      #   YAML.dump(@privmemos,fh)
      # end
    end
  end

  def make_msg(nick, text, time)
    t = time.strftime("%Y-%m-%d")
    #{}"<#{nick}/#{t}> #{text}"
    ":Note from #{nick} on #{t}: #{text}"
  end
end

class Weather

  include Cinch::Plugin
    match /wea (.+)/
    #match /forecast (.+)/

    #use geocoder to grab longitude and latitude 

  def location(query)

    def celsius_to_fahrenheit(celsius)
      celsius * 9 / 5 + 32
    end
    ForecastIO.api_key = "3c15954606092982f23336badca3586b"

    location = Geocoder.search(query)
    address = location[0].data["formatted_address"]
    location = location[0].data["geometry"]["location"].flatten
    #if address.match('USA') 
    #  units = "F"
    #end

    weather = ForecastIO.forecast(location[1],location[3],params: { units: "si" })
   
    current_temp = weather.currently.temperature.round
    current = weather.currently.summary
    tomorrow = weather.daily.data[1].summary
    tomorrow_lowtemp = weather.daily.data[1].temperatureMin.round
    tomorrow_hightemp = weather.daily.data[1].temperatureMax.round
    address + ": Now: #{current}, #{current_temp}°C" + " (#{celsius_to_fahrenheit(current_temp.to_i)}°F)" + " Tomorrow: #{tomorrow} #{tomorrow_lowtemp}-#{tomorrow_hightemp}°C" + " (#{celsius_to_fahrenheit(tomorrow_lowtemp.to_i)}-#{celsius_to_fahrenheit(tomorrow_hightemp.to_i)}°F)" 
  rescue
    "You're silly, try again"
  end

  def execute(m, query)
    m.reply location(query)
  end

end

# class Bookmark
#   include Cinch::Plugin
#   match /bookmark (.+)/
#   match /(.+)/

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
    #c.channels = ["#ffatest"]
    c.plugins.plugins = [Google, DoMath, UrbanDictionary, Wolframsearch, Memo, Weather, Cat]
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
