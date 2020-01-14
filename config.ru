# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

use Rack::CanonicalHost, ENV["HOSTNAME"] if ENV["HOSTNAME"].present?

if ENV["HTTP_BASIC_AUTH_USERNAME"] && ENV["HTTP_BASIC_AUTH_PASSWORD"]
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV["HTTP_BASIC_AUTH_USERNAME"] && password == ENV["HTTP_BASIC_AUTH_PASSWORD"]
  end
end

run Rails.application
