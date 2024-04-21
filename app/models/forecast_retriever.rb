class ForecastRetriever
  include GeolocateService

  def retrieve_forecast(address:)
    parsed_address = parse_address(address: address)
    # Some addresses around the world don't include postal codes apparently, but our system is currently
    # designed to key off of postal_code, so reject requests for those. I've come across a handful of
    # places that don't use postal codes so far (Ireland, Mongolia, Antarctica), but none in the US,
    # which is the main target here. For an invalid address, parsed_address will just be nil.
    if parsed_address.nil? || parsed_address.components["postal_code"].nil?
      Rails.logger.error("Could not geocode address #{address}")
      return invalid_address(address)
    end

    zipcode = parsed_address.components["postal_code"][0]
    if zipcode.nil?
      Rails.logger.error("Could not determine a postal code from address #{address}")
      return invalid_address(address)
    end
    country_param = parsed_address.components["country"][0]&.parameterize

    forecast = WeatherForecast.find_by(zipcode: zipcode, country: country_param)
    if forecast.nil? || forecast.expired?
      forecast_data = weather_service.retrieve_weather(latitude: parsed_address.latitude, longitude: parsed_address.longitude)
      upcoming_forecast_data = weather_service.retrieve_weather_forecast(latitude: parsed_address.latitude, longitude: parsed_address.longitude)
      # TODO: add error handling, update! and create! will both fail if we couldn't get the weather or the forecast. Need to better handle the errors.
      if forecast
        forecast.update!(forecast_data: forecast_data, upcoming_forecast_data: upcoming_forecast_data, cached: false)
      else
        forecast = WeatherForecast.create!(country: country_param, zipcode: zipcode, forecast_data: forecast_data, upcoming_forecast_data: upcoming_forecast_data)
      end
    end

    forecast
  end

  private

  def parse_address(address:)
    result = geocode_address(address: address)
    unless result
      Rails.logger.error "Failed to geocode the provided address: `#{address}`"
      return nil
    end

    # if we got an address without a postal code (search term was likely too generic and encompassed several, e.g. 'California'),
    # re-run the query for the coordinates from this result, which will pinpoint to a specific location, with a single postal code
    if result.components["postal_code"].nil?
      result = geocode_address(address: "#{result.latitude}, #{result.longitude}")
      Rails.logger.error "Failed to geocode the provided address: `#{result.latitude}, #{result.longitude}`" unless result
    end

    result
  end

  def invalid_address(address)
    forecast = WeatherForecast.new(address: address)
    forecast.errors.add(:address, "could not be parsed")
    forecast
  end

  def weather_service
    @weather_service ||= WeatherService.new(Forecasts::Application.config.open_weather_map_api_key)
  end
end