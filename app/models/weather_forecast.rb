class WeatherForecast < ApplicationRecord
  CACHE_LIMIT_IN_MINUTES = 30.minutes

  attr_accessor :address

  scope :recent, -> { where("updated_at > ?", DateTime.now - CACHE_LIMIT_IN_MINUTES) }
  # Add a background job to clean up expired forecasts?
  # Likely not a lot of harm in keeping them around, as the db size should remain pretty manageable,
  # but potentially an option for the future.
  scope :expired, -> { where("updated_at < ?", DateTime.now - CACHE_LIMIT_IN_MINUTES) }

  validates :zipcode, uniqueness: true

  def expired?
    updated_at < DateTime.now - CACHE_LIMIT_IN_MINUTES
  end
end