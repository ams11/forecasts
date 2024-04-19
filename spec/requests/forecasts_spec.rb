require 'rails_helper'
require 'forecasts_spec_helper'

RSpec.describe "/forecasts", type: :request do
  include ForecastsSpecHelper

  let(:lat) { 47.56 }
  let(:lon) { -122.28 }
  let(:zipcode) { "98345" }

  describe "GET /show" do
    it "renders a successful response" do
      stub_geocode(lat: lat, lon: lon, zipcode: zipcode, address: zipcode)
      stub_forecast(lat: lat, lon: lon)

      get forecast_url(zipcode)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_forecast_url
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    let(:address) { Faker::Address.full_address }
    let(:attributes) {
      { address: address }
    }

    describe "with valid parameters" do
      before do
        stub_geocode(lat: lat, lon: lon, zipcode: zipcode, address: address)
        stub_forecast(lat: lat, lon: lon)
      end

      it "creates a new WeatherForecast" do
        expect {
          post forecasts_url, params: { weather_forecast: attributes }
        }.to change(WeatherForecast, :count).by(1)
      end

      it "redirects to the new forecast" do
        post forecasts_url, params: { weather_forecast: attributes }
        expect(response).to redirect_to(forecast_url(WeatherForecast.last.zipcode))
      end
    end

    describe "with invalid parameters" do
      let(:address) { nil }

      before do
        stub_geocode(lat: lat, lon: lon, zipcode: zipcode, address: address, location: nil)
      end

      it "does not create a new WeatherForecast" do
        expect {
          post forecasts_url, params: { weather_forecast: attributes }
        }.to change(WeatherForecast, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post forecasts_url, params: { weather_forecast: attributes }
        expect(response.code).to eq("200")
        expect(response).to have_rendered("new")
      end
    end
  end
end
