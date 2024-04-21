require 'rails_helper'
require 'forecasts_spec_helper'

RSpec.describe ForecastRetriever, type: :model do
  include ForecastsSpecHelper

  let(:forecast_retriever) { ForecastRetriever.new }
  let(:zipcode) { Faker::Address.zip_code }
  let(:country) { "united-states" }
  let(:lat) { 47.56 }
  let(:lon) { -122.28 }

  describe ".retrieve_forecast" do
    let(:address) { Faker::Address.full_address }
    let(:postal_code) { [zipcode] }

    before do
      stub_geocode(lat: lat, lon: lon, zipcode: zipcode, address: address, postal_code: postal_code)
    end

    describe "when calling the weather service" do
      before do
        stub_forecast(lat: lat, lon: lon)
      end

      it "creates a new WeatherForecast for a zipcode we haven't seen before" do
        expect do
          forecast = forecast_retriever.retrieve_forecast(address: address)
          expect(forecast).to be_valid
          expect(forecast.zipcode).to eq(zipcode)
          expect(forecast.cached).to eq(false)
          expect(forecast.forecast_data).to eq(ForecastsSpecHelper::WEATHER_JSON)
          expect(forecast.upcoming_forecast_data).to eq(ForecastsSpecHelper::FORECAST_JSON)
        end.to change(WeatherForecast, :count)
      end

      it "updates an existing record if we've seen this zipcode before, but it's expired" do
        forecast = create(:weather_forecast, :expired, zipcode: zipcode)
        expect do
          forecast_retriever.retrieve_forecast(address: address)
        end.not_to change(WeatherForecast, :count)

        forecast.reload
        expect(forecast.zipcode).to eq(zipcode)
        expect(forecast.cached).to eq(false)
        expect(forecast.forecast_data).to eq(ForecastsSpecHelper::WEATHER_JSON)
        expect(forecast.upcoming_forecast_data).to eq(ForecastsSpecHelper::FORECAST_JSON)
      end
    end

    it "returns the existing forecast without updating it if it is not expired" do
      expect_any_instance_of(WeatherService).not_to receive(:retrieve_weather)
      expect_any_instance_of(WeatherService).not_to receive(:retrieve_weather_forecast)

      forecast = create(:weather_forecast, zipcode: zipcode, country: country)
      timestamp = forecast.updated_at
      expect do
        forecast_retriever.retrieve_forecast(address: address)
      end.not_to change(WeatherForecast, :count)

      forecast.reload
      expect(forecast.zipcode).to eq(zipcode)
      expect(forecast.updated_at).to eq(timestamp)
    end

    describe "if the geocode did not return a zipcode" do
      let(:postal_code) { nil }
      let(:address) { "California" }
      let(:second_zipcode) { Faker::Address.zip_code }

      before do
        stub_geocode(lat: lat, lon: lon, zipcode: second_zipcode, address: "#{lat}, #{lon}", postal_code: [second_zipcode])
        stub_forecast(lat: lat, lon: lon)
      end

      it "gets the location from the lat/lon and gets the forecast successfully" do
        expect do
          forecast = forecast_retriever.retrieve_forecast(address: address)
          expect(forecast).to be_valid
          expect(forecast.zipcode).to eq(second_zipcode)
          expect(forecast.cached).to eq(false)
          expect(forecast.forecast_data).to eq(ForecastsSpecHelper::WEATHER_JSON)
          expect(forecast.upcoming_forecast_data).to eq(ForecastsSpecHelper::FORECAST_JSON)
        end.to change(WeatherForecast, :count)
      end
    end

    describe "if given an address that does not resolve to a postal code" do
      let(:postal_code) { nil }
      let(:address) { "Olgiy, Mongolia" } # Mongolia does not appear to use postal codes(?)

      before do
        stub_geocode(lat: lat, lon: lon, zipcode: zipcode, address: "#{lat}, #{lon}", postal_code: [nil])
      end

      it "returns a WeatherForecast with an error" do
        expect(Rails.logger).to receive(:error).once.with("Could not determine a postal code from address #{address}")
        # expect(Rails.logger).to receive(:error).once.with("Could not geocode address #{address}")
        forecast = forecast_retriever.retrieve_forecast(address: address)
        expect(forecast.errors.messages[:address]).to include("could not be parsed")
      end
    end
  end
end
