require 'rails_helper'

RSpec.describe WeatherForecast, type: :model do
  describe "validations" do
    it "flags any missing fields that are required" do
      weather_forecast = WeatherForecast.new(country: nil)
      expect(weather_forecast).not_to be_valid
      expect(weather_forecast.errors.count).to eq(4)

      expect(weather_forecast.errors.messages[:zipcode]).to include("can't be blank")
      expect(weather_forecast.errors.messages[:country]).to include("can't be blank")
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

    it "allows duplicate zipcodes in different countries" do
      weather_forecast = create(:weather_forecast, country: "japan")
      expect(weather_forecast).to be_valid
      weather_forecast_dupe = build(:weather_forecast, zipcode: weather_forecast.zipcode, country: "argentina")
      expect(weather_forecast_dupe).to be_valid
    end
  end

  describe ".expired?" do
    let(:active_forecast) { create(:weather_forecast, updated_at: DateTime.now - WeatherForecast::CACHE_LIFETIME + 2.minutes) }
    let(:expired_forecast) { create(:weather_forecast, :expired) }

    it "returns true if the record was updated more than CACHE_LIFETIME ago" do
      expect(expired_forecast).to be_expired
    end

    it "returns false if record was updated less than CACHE_LIFETIME ago" do
      expect(active_forecast).not_to be_expired
    end

    it "is included in the recent scope if the forecast is not expired" do
      expect(WeatherForecast.recent).to include(active_forecast)
      expect(WeatherForecast.recent).not_to include(expired_forecast)
    end

    it "is included in the expired scope if the forecast is not expired" do
      expect(WeatherForecast.expired).to include(expired_forecast)
      expect(WeatherForecast.expired).not_to include(active_forecast)
    end
  end
end
