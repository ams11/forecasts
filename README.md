# Forecasts App

Installation and running instructions:
 - You will need Ruby 3.0.0. If using rvm, or similar manager, you may be able to run something like `rvm install 3.0.0` to install it.
 - install bundler `gem install bundle`
 - install dependencies: `bundle install`
 - the app uses the Sqlite database, make sure it's installed, then 
 - create and initialize your database: `rails db:create db:migrate`
 - create a `.env` file for storing secrets (you can copy the included `.env_sample`) and populate it with your keys for https://openweathermap.org/api and https://console.cloud.google.com/google/maps-apis/overview. You can use free keys, though Google will ask you to set up a billing profile. I did not include the keys in the repo, please reach out if you need help in setting them up.
 - start the server locally: `rails s`
 - you can now navigate to the home page at `http://localhost:3000` and enter an address to get a weather forecast

Application notes:
 - you can enter any address, the app uses the Google Maps API to parse and geocode it and correlate with a zipcode (or postal code if international). Addresses that cannot be parsed, or resolve to a location without a postal code (e.g. Antarctica, but also certain countries including Ireland and Mongolia) are rejected. Entering an address that span multiple zipcode (e.g. "California") will resolve to the location that Google has assigned to it. The app then retrieves the weather for the selected location and redirects to a page for showing it, with the url key-ed off the zipcode.
 - the weather info is re-used for any additional requests that resolve to that same zipcode for the next 30 minutes (and labeled as cached). After 30 minutes, the cache is expired, and the next request will query the weather again.
 - the application also retrieves a 7 day forecast and includes it in the results, along with a map of the requested location
 - the standard workflow is to enter the address for the weather information on the home page, which will then retrieve the weather info and redirect the user to the display page. Alternatively, it's possible to navigate directly to the display page (e.g. http://localhost:3000/forecasts/90210), without first having queried for the weather for that zipcode, and the app will automatically retrieve weather info (assuming a valid zipcode)

Known issues:
 - the forecasts are keyed off of postal codes from around the world, however, the postal codes are not limited by country, so it is possible to have a conflict, as postal codes can be the same in different countries. For example, 08007 is the postal code for a neighborhood in Barcelona, Spain, as well as the town of Barrington, NJ in the US. The better long term solution would be to store the country id and the postal code and include both in the route for the weather display. 

Testing:
 - there are RSpec unit tests for the models, requests (controllers), routes, and views in the app. The application makes several calls to external services - Google Maps for geocoding an address and the Open Weather API to get the weather info - the external calls are disabled and stubbed out in all the relevant tests. 