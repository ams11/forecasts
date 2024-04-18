module GeolocateService
  def geocode_address(address:)
    Google::Maps.geocode(address)[0]
  end
end
