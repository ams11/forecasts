require_relative "../forecasts_spec_helper"

FactoryBot.define do
  factory :weather_forecast do
    zipcode { Faker::Address.zip_code }
    country { "united-states" }
    forecast_data { ForecastsSpecHelper::WEATHER_JSON }
    upcoming_forecast_data { ForecastsSpecHelper::FORECAST_JSON }

    trait :expired do
      updated_at { DateTime.now - WeatherForecast::CACHE_LIFETIME - 1.hour }
    end
  end
end
