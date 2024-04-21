class AddCountryToWeatherForecasts < ActiveRecord::Migration[7.0]
  def change
    add_column :weather_forecasts, :country, :string
  end
end
