require "pwr"
require 'rack/google_analytics'

use Rack::GoogleAnalytics, :web_property_id => "UA-9997784-6"
run Sinatra::Application
