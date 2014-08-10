require "forecast_io"
require "geocoder"

def celsius_to_fahrenheit(celsius)
      celsius * 9 / 5 + 32
    end

ForecastIO.api_key = "3c15954606092982f23336badca3586b"

location = "tpe"
location = Geocoder.search(location)
address = location[0].data["formatted_address"]
location = location[0].data["geometry"]["location"].flatten
#location = location.flatten 


weather = ForecastIO.forecast(location[1],location[3],params: { units: "si" })
 
 current_temp=weather.currently.temperature.round
 current=weather.currently.summary
 tomorrow=weather.daily.data[1].summary
 tomorrow_lowtemp=weather.daily.data[1].temperatureMin.round
 
 tomorrow_hightemp=weather.daily.data[1].temperatureMax.round weather=
 address+":Now:#{current},#{current_temp}°C"+"(#{celsius_to_fahrenheit
 (current_temp)}°F)"+"Tomorrow:#{tomorrow}#{tomorrow_lowtemp}-#{tomorr
 ow_hightemp}°C"+"(#{celsius_to_fahrenheit(tomorrow_lowtemp)}-#{celsiu
 s_to_fahrenheit(tomorrow_hightemp)}°F)"+".Thisweek:#{weather.daily.su
 mmary}" 
 putsweather
