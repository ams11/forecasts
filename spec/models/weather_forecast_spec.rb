require 'rails_helper'

RSpec.describe WeatherForecast, type: :model do
  describe "validations" do
    it "flags any missing fields that are required" do
      weather_forecast = WeatherForecast.new
      expect(weather_forecast).not_to be_valid
      expect(weather_forecast.errors.count).to eq(3)

      expect(weather_forecast.errors.messages[:zipcode]).to include("can't be blank")
      expect(weather_forecast.errors.messages[:upcoming_forecast_data]).to include("can't be blank")
      expect(weather_forecast.errors.messages[:forecast_data]).to include("can't be blank")
    end

    it "marks a forecast with a duplicate zipcode as invalid" do
      weather_forecast = create(:weather_forecast)
      expect(weather_forecast).to be_valid
      weather_forecast_dupe = build(:weather_forecast, zipcode: weather_forecast.zipcode)
      expect(weather_forecast_dupe).not_to be_valid
      expect(weather_forecast_dupe.errors.messages[:zipcode]).to include("has already been taken")
    end
  end

  describe ".expired?" do
    it "returns true if the record was updated more than CACHE_LIFETIME ago" do
      weather_forecast = build(:weather_forecast, updated_at: DateTime.now - WeatherForecast::CACHE_LIFETIME - 1.minute)
      expect(weather_forecast).to be_expired
    end
  end
end
