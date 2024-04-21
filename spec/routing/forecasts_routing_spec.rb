require "rails_helper"

RSpec.describe ForecastsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/forecasts/new").to route_to("forecasts#new")
    end

    it "routes to #create" do
      expect(post: "/forecasts").to route_to("forecasts#create")
    end

    it "routes to #zipcode_forecast" do
      zipcode = "12345"
      expect(get: "/forecasts/#{zipcode}").to route_to("forecasts#show", zipcode: zipcode)
    end

    it "routes to #country_zipcode_forecast" do
      country = "spain"
      zipcode = "12345"
      expect(get: "/forecasts/#{country}/#{zipcode}").to route_to("forecasts#show", country: country, zipcode: zipcode)
    end
  end
end
