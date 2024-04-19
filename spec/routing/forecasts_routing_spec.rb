require "rails_helper"

RSpec.describe ForecastsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/forecasts/new").to route_to("forecasts#new")
    end

    it "routes to #show" do
      zipcode = "12345"
      expect(get: "/forecasts/#{zipcode}").to route_to("forecasts#show", id: zipcode)
    end

    it "routes to #create" do
      expect(post: "/forecasts").to route_to("forecasts#create")
    end
  end
end
