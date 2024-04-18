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
  end
end
