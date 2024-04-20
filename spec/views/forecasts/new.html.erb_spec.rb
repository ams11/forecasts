require 'rails_helper'

RSpec.describe "forecasts/new", type: :view do
  it "renders new forecast form" do
    forecast = WeatherForecast.new

    render template: "forecasts/new", locals: { forecast: forecast }

    assert_select "form[action=?][method=?]", forecasts_path, "post" do

      assert_select "input[name=?]", "weather_forecast[address]"
      assert_select "input[value=?]", "Get Weather"
    end
  end
end
