Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :forecasts, only: [:new, :create]

  get "/forecasts/:country/:zipcode", to: "forecasts#show", as: :"country_zipcode_forecast"
  get "/forecasts/:zipcode", to: "forecasts#show", as: :"zipcode_forecast"

  root "forecasts#new"
end
