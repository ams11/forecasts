module GeolocateService
  # list of supported countries - TODO: need a full list that Google Maps supports
  COUNTRIES = [
    "United States",
    "Canada",
    "Spain",
    "Germany",
    "Japan",
    "Mongolia",
    "China",
    "Taiwan",
    "South Korea",
    "Argentina",
  ]
  COUNTRY_MAP = COUNTRIES.to_h { |country_name| [country_name.parameterize, country_name] }

  def geocode_address(address:)
    Google::Maps.geocode(address)[0]
  end
end
