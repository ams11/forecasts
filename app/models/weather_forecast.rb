class WeatherForecast < ApplicationRecord
  CACHE_LIFETIME = 30.minutes

  attr_accessor :address

  scope :recent, -> { where("updated_at > ?", DateTime.now - CACHE_LIFETIME) }
  # Add a background job to clean up expired forecasts?
  # Likely not a lot of harm in keeping them around, as the db size should remain pretty manageable,
  # but potentially an option for the future.
  scope :expired, -> { where("updated_at < ?", DateTime.now - CACHE_LIFETIME) }

  validates :zipcode, uniqueness: { scope: :country }
  validates :country, :zipcode, :forecast_data, :upcoming_forecast_data, presence: true

  def expired?
    updated_at < DateTime.now - CACHE_LIFETIME
  end
end