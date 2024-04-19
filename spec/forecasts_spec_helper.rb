module ForecastsSpecHelper
  WEATHER_JSON = {
    "coord"=>{"lon"=>-122.2892, "lat"=>47.633},
    "weather"=>[{"id"=>800, "main"=>"Clear", "description"=>"clear sky", "icon"=>"01n"}],
    "base"=>"stations",
    "main"=>{"temp"=>48.51, "feels_like"=>44.92, "temp_min"=>41.5, "temp_max"=>54.18, "pressure"=>1022, "humidity"=>54},
    "visibility"=>10000,
    "wind"=>{"speed"=>8.05, "deg"=>310},
    "clouds"=>{"all"=>0},
    "dt"=>1713507286,
    "sys"=>{"type"=>2, "id"=>2041694, "country"=>"US", "sunrise"=>1713445999, "sunset"=>1713495778},
    "timezone"=>-25200,
    "id"=>5809844,
    "name"=>"Seattle",
    "cod"=>200
  }
  FORECAST_JSON = {
    "lat"=>47.633,
    "lon"=>-122.2892,
    "timezone"=>"America/Los_Angeles",
    "timezone_offset"=>-25200,
    "daily"=>
      [{"dt"=>1713470400,
        "sunrise"=>1713445999,
        "sunset"=>1713495778,
        "moonrise"=>1713476820,
        "moonset"=>1713440400,
        "moon_phase"=>0.34,
        "summary"=>"There will be clear sky today",
        "temp"=>{"day"=>59.81, "min"=>39.6, "max"=>61.21, "night"=>48.51, "eve"=>54.18, "morn"=>40.62},
        "feels_like"=>{"day"=>57.04, "night"=>46.89, "eve"=>51.26, "morn"=>37.49},
        "pressure"=>1024,
        "humidity"=>33,
        "dew_point"=>30.31,
        "wind_speed"=>11.45,
        "wind_deg"=>347,
        "wind_gust"=>20.83,
        "weather"=>[{"id"=>800, "main"=>"Clear", "description"=>"clear sky", "icon"=>"01d"}],
        "clouds"=>3,
        "pop"=>0,
        "uvi"=>4.37}
      ]
  }

  def stub_geocode(
    lat:, lon:, zipcode:,
    address: Faker::Address.full_address,
    location: instance_double("Google::Maps::Location", latitude: lat, longitude: lon),
    postal_code: [zipcode]
    )
    allow(location).to receive(:components).and_return({ "postal_code" => postal_code })
    expect(Google::Maps).to receive(:geocode).with(address).once.and_return([location])
  end

  def stub_forecast(
    lat:,
    lon:,
    weather_json: WEATHER_JSON,
    forecast_json: FORECAST_JSON
  )
    expect_any_instance_of(WeatherService).to receive(:retrieve_weather).once.with(latitude: lat, longitude: lon).and_return(weather_json)
    expect_any_instance_of(WeatherService).to receive(:retrieve_weather_forecast).once.with(latitude: lat, longitude: lon).and_return(forecast_json)
  end
end
