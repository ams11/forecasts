require 'httparty'

class WeatherService
  def initialize(app_id)
    @app_id = app_id
  end

  def retrieve_weather(latitude:, longitude:)
    weather_url = "https://api.openweathermap.org/data/2.5/weather?lat=#{latitude}&lon=#{longitude}&appid=#{@app_id}&units=imperial"
    HTTParty.get(weather_url)
  end

  def retrieve_weather_forecast(latitude:, longitude:)
    forecast_url = "https://api.openweathermap.org/data/3.0/onecall?lat=#{latitude}&lon=#{longitude}&exclude=hourly,minutely,current&appid=#{@app_id}&units=imperial"
    HTTParty.get(forecast_url)
  end
end