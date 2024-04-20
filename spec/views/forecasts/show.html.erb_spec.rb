require 'rails_helper'

RSpec.describe "forecasts/show", type: :view do
  include ForecastsHelper

  before(:each) do
    @forecast = create(:weather_forecast)
  end

  it "renders forecast data" do
    render template: "forecasts/show", locals: { forecast_info: weather_display_info(@forecast) }

    expect(rendered).to match(/Forecast for/)
    expect(rendered).to match(@forecast.zipcode)
    expect(rendered).to match(@forecast.forecast_data["main"]["temp"].to_s)
    expect(rendered).to match(@forecast.forecast_data["main"]["temp_min"].to_s)
    expect(rendered).to match(@forecast.forecast_data["main"]["temp_max"].to_s)
    expect(rendered).to match(/Temperature/)
    expect(rendered).to match(/7 Day Forecast:/)
  end

  it "shows the Cached label for a cached forecast" do
    expect(@forecast.update(cached: true)).to eq(true)

    render template: "forecasts/show", locals: { forecast_info: weather_display_info(@forecast) }

    expect(rendered).to match(/Forecast for/)
    expect(rendered).to match(@forecast.zipcode)
    expect(rendered).to match(/Cached/)
  end
end
