class CreateWeatherForecasts < ActiveRecord::Migration[7.0]
  def change
    create_table :weather_forecasts do |t|
      t.string :zipcode, null: false
      t.boolean :cached, null: false, default: false
      t.json :forecast_data, null: false
      t.json :upcoming_forecast_data, null: false

      t.timestamps
    end
  end
end
