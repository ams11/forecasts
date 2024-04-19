require 'rails_helper'

RSpec.describe ForecastRetriever, type: :model do
  let(:forecast_retriever) { ForecastRetriever.new }
  let(:zipcode) { Faker::Address.zip_code }
  let(:lat) { 47.56 }
  let(:lon) { -122.28 }
  let(:weather_json) do
    {
      "coord"=>{"lon"=>-122.2892, "lat"=>47.633},
      "weather"=>[{"id"=>800, "main"=>"Clear", "description"=>"clear sky", "icon"=>"01n"}],
      "base"=>"stations",
      "main"=>{"temp"=>48.51, "feels_like"=>44.92, "temp_min"=>41.5, "temp_max"=>54.18, "pressure"=>1022, "humidity"=>54},
      "visibility"=>10000,
      "wind"=>{"speed"=>8.05, "deg"=>310},
      "clouds"=>{"all"=>0},
      "dt"=>1713507286,
      "sys"=>{"type"=>2, "id"=>2041694, "country"=>"US", "sunrise"=>1713445999, "sunset"=>1713495778},
      "timezone"=>-25200,
      "id"=>5809844,
      "name"=>"Seattle",
      "cod"=>200
    }
  end
  let(:forecast_json) do
    {
      "lat"=>47.633,
      "lon"=>-122.2892,
      "timezone"=>"America/Los_Angeles",
      "timezone_offset"=>-25200,
      "daily"=>
       [{"dt"=>1713470400,
         "sunrise"=>1713445999,
         "sunset"=>1713495778,
         "moonrise"=>1713476820,
         "moonset"=>1713440400,
         "moon_phase"=>0.34,
         "summary"=>"There will be clear sky today",
         "temp"=>{"day"=>59.81, "min"=>39.6, "max"=>61.21, "night"=>48.51, "eve"=>54.18, "morn"=>40.62},
         "feels_like"=>{"day"=>57.04, "night"=>46.89, "eve"=>51.26, "morn"=>37.49},
         "pressure"=>1024,
         "humidity"=>33,
         "dew_point"=>30.31,
         "wind_speed"=>11.45,
         "wind_deg"=>347,
         "wind_gust"=>20.83,
         "weather"=>[{"id"=>800, "main"=>"Clear", "description"=>"clear sky", "icon"=>"01d"}],
         "clouds"=>3,
         "pop"=>0,
         "uvi"=>4.37}
       ]
    }
  end

  describe ".retrieve_forecast" do
    let(:address) { Faker::Address.full_address }
    let(:location) { instance_double("Google::Maps::Location", latitude: lat, longitude: lon) }
    let(:postal_code) { [zipcode] }

    before do
      allow(location).to receive(:components).and_return({ "postal_code" => postal_code })
      expect(Google::Maps).to receive(:geocode).with(address).once.and_return([location])
    end

    describe "when calling the weather service" do
      before do
        expect_any_instance_of(WeatherService).to receive(:retrieve_weather).once.with(latitude: lat, longitude: lon).and_return(weather_json)
        expect_any_instance_of(WeatherService).to receive(:retrieve_weather_forecast).once.with(latitude: lat, longitude: lon).and_return(forecast_json)
      end

      it "creates a new WeatherForecast for a zipcode we haven't seen before" do
        expect do
          forecast = forecast_retriever.retrieve_forecast(address: address)
          expect(forecast).to be_valid
          expect(forecast.zipcode).to eq(zipcode)
          expect(forecast.cached).to eq(false)
          expect(forecast.forecast_data).to eq(weather_json)
          expect(forecast.upcoming_forecast_data).to eq(forecast_json)
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
        expect(forecast.forecast_data).to eq(weather_json)
        expect(forecast.upcoming_forecast_data).to eq(forecast_json)
      end
    end

    it "returns the existing forecast without updating it if it is not expired" do
      expect_any_instance_of(WeatherService).not_to receive(:retrieve_weather)
      expect_any_instance_of(WeatherService).not_to receive(:retrieve_weather_forecast)

      forecast = create(:weather_forecast, zipcode: zipcode)
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
      let(:full_location) { instance_double("Google::Maps::Location", latitude: lat, longitude: lon) }

      before do
        allow(full_location).to receive(:components).and_return({ "postal_code" => [second_zipcode] })
        expect(Google::Maps).to receive(:geocode).with("#{lat}, #{lon}").once.and_return([full_location])
        expect_any_instance_of(WeatherService).to receive(:retrieve_weather).once.with(latitude: lat, longitude: lon).and_return(weather_json)
        expect_any_instance_of(WeatherService).to receive(:retrieve_weather_forecast).once.with(latitude: lat, longitude: lon).and_return(forecast_json)
      end

      it "gets the location from the lat/lon and gets the forecast successfully" do
        expect do
          forecast = forecast_retriever.retrieve_forecast(address: address)
          expect(forecast).to be_valid
          expect(forecast.zipcode).to eq(second_zipcode)
          expect(forecast.cached).to eq(false)
          expect(forecast.forecast_data).to eq(weather_json)
          expect(forecast.upcoming_forecast_data).to eq(forecast_json)
        end.to change(WeatherForecast, :count)
      end
    end
  end
end
