require "forecast_io"
require "geocoder"

class Weather
  include Cinch::Plugin

    match /wea (.+?) (.+)/

    #use geocoder to grab longitude and latitude 

  def location(query)
    ForecastIO.api_key = "3c15954606092982f23336badca3586b"

    location = Geocoder.search(query)
    location = location[0].data["geometry"]["location"]
    location = location.flatten #lat = [1] lng = [3]

    weather = ForecastIO.forecast(location[1],location[3])

    weather.currently
  end

  def execute(m, query)
    m.reply location(query)
  end

end

