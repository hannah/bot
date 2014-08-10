require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'

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