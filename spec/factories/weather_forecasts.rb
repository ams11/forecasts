FactoryBot.define do
  factory :weather_forecast do
    zipcode { Faker::Address.zip_code }
    upcoming_forecast_data { { lat: 47, lon: 122 } }
    forecast_data { { lat: 47, lon: 122 } }

    trait :expired do
      updated_at { DateTime.now - WeatherForecast::CACHE_LIFETIME - 1.hour }
    end
  end
end
