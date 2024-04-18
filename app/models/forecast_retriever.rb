class ForecastRetriever
  include GeolocateService

  def retrieve_forecast(address:)
    parsed_address = parse_address(address: address)
    # Some addresses around the world don't include postal codes apparently, but our system is currently
    # designed to key off of postal_code, so reject requests for those. I've come across a handful of
    # places that don't use postal codes so far (Ireland, Mongolia, Antarctica), but none in the US,
    # which is the main target here. For an invalid address, parsed_address will just be nil.
    if parsed_address.nil? || parsed_address.components["postal_code"].nil?
      forecast = WeatherForecast.new(address: address)
      forecast.errors.add(:address, "could not be parsed")
      return forecast
    end

    zipcode = parsed_address.components["postal_code"][0]

    forecast = WeatherForecast.find_by(zipcode: zipcode)
    if forecast.nil? || forecast.expired?
      forecast_data = weather_service.retrieve_weather(latitude: parsed_address.latitude, longitude: parsed_address.longitude)
      upcoming_forecast_data = weather_service.retrieve_weather_forecast(latitude: parsed_address.latitude, longitude: parsed_address.longitude)
      # TODO: add error handling, currently not catching the errors if update! or create! raises
      if forecast
        forecast.update!(forecast_data: forecast_data, upcoming_forecast_data: upcoming_forecast_data, cached: false)
      else
        forecast = WeatherForecast.create!(zipcode: zipcode, forecast_data: forecast_data, upcoming_forecast_data: upcoming_forecast_data)
      end
    end

    forecast
  end

  def parse_address(address:)
    result = geocode_address(address: address)
    return nil unless result

    # if we got an address without a postal code (search term was likely too generic and encompassed several, e.g. 'California'),
    # re-run the query for the coordinates from this result, which will pinpoint to a specific location, with a single postal code
    if result.components["postal_code"].nil?
      result = geocode_address(address: "#{result.latitude}, #{result.longitude}")
    end

    result
  end

  private

  def weather_service
    @weather_service ||= WeatherService.new(Forecasts::Application.config.open_weather_map_api_key)
  end
end