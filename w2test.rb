require 'wolfram'
require 'nokogiri'

Wolfram.appid = "855858-G8QRY7HHWQ"

query = 'weather vancouver'
result = Wolfram.fetch(query)
hash = Wolfram::HashPresenter.new(result).to_hash

array = hash.flatten
puts array[1]
