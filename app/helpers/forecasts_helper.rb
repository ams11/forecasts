module ForecastsHelper
  include ActionView::Helpers::DateHelper

  def weather_display_info(weather_forecast)
    forecast_data = weather_forecast.forecast_data

    {
      cached: weather_forecast.cached? ? time_ago_in_words(weather_forecast.updated_at) : nil,
      zipcode: weather_forecast.zipcode,
      location: forecast_data["name"],
      temperature: forecast_data["main"]["temp"],
      day_min: forecast_data["main"]["temp_min"],
      day_max: forecast_data["main"]["temp_max"],
      conditions: forecast_data["weather"].first["main"],
      wind: "#{forecast_data['wind']['speed']} miles per hour at #{forecast_data['wind']['deg']} degrees",
      upcoming_weather_data: forecast_info_from_weather(weather_forecast.upcoming_forecast_data),
    }
  end

  def forecast_info_from_weather(forecast_data)
    return [] if forecast_data.blank? || forecast_data["daily"].blank?

    forecast_data["daily"].to_h do |day_forecast|
      [Time.at(day_forecast["dt"]).to_date, { min: day_forecast["temp"]["min"], max: day_forecast["temp"]["max"] }]
    end
  end
end