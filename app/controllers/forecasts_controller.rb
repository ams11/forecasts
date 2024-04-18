class ForecastsController < ApplicationController
  include ForecastsHelper

  before_action :validate_forecast, only: :show
  after_action :mark_as_cached, only: :show

  def show
    render "show", locals: { forecast_info: weather_display_info(forecast) }
  end

  def new
    forecast = WeatherForecast.new
    render "new", locals: { forecast: forecast }
  end

  def create
    @forecast = retrieve_forecast(address: weather_forecast_params.fetch(:address))
    if @forecast.nil? || @forecast.errors.any?
      render "new", locals: { forecast: @forecast }
    else
      redirect_to forecast_path(@forecast.zipcode)
    end
  end

  private

  def validate_forecast
    unless forecast
      # support retrieving new weather forecasts by navigating directly to the url for a specific zipcode
      forecast_retriever = ForecastRetriever.new
      @forecast = forecast_retriever.retrieve_forecast(address: forecast_zipcode_param)
      if @forecast.nil? || @forecast.errors.any?
        render "new", locals: { forecast: @forecast } and return
      end
    end
  end

  def retrieve_forecast(address:)
    forecast_retriever = ForecastRetriever.new
    forecast_retriever.retrieve_forecast(address: address)
  end

  def mark_as_cached
    # cheat a little bit and don't change the updated_at date here, so we can accurately track when forecasts expire
    forecast.update!(cached: true, updated_at: forecast.updated_at)
  end

  def forecast
    @forecast ||= WeatherForecast.recent.find_by(zipcode: forecast_zipcode_param)
  end

  def forecast_zipcode_param
    params.permit(:id).fetch(:id)
  end

  def weather_forecast_params
    params.require(:weather_forecast).permit(:address)
  end
end