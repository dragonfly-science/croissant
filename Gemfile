source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version")

gem "rails", "~> 6.0"
gem "puma", "~> 4.3"
gem "pg", ">= 0.18"
gem 'dotenv-rails', require: "dotenv/rails-now"
gem "bootsnap", ">= 1.4.2", require: false
gem "sassc-rails"
gem "redis", "~> 4.0"
gem "sidekiq", ">= 4.2.0"
gem "webpacker", "~> 4.0"
gem "devise"
gem "pundit"
gem "paper_trail" # audit log
gem "loaf" # breadcrumbs
gem "kaminari" # pagination
gem "docx" # reading .docx files
gem "charlock_holmes" # encoding detection

gem "activestorage-validator"
gem "image_processing", "~> 1.0"
gem "pdf-reader"
gem "aws-sdk-s3", require: false
gem "sendgrid-ruby"

gem 'state_machines-activerecord'

gem "rack-canonical-host", "~> 0.2.3"

gem "bootstrap_form", "~> 4.0"

gem "roo", "~> 2.8.0" # xlsx converter

group :development do
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "simplecov", require: false
  gem "rubocop", ">= 0.70.0", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "letter_opener"

  # Required in Rails 5 by ActiveSupport::EventedFileUpdateChecker
  gem "listen", ">= 3.0.5"
  gem "overcommit", ">= 0.37.0", require: false
  gem "better_errors"
  gem "binding_of_caller"
end

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "pry-rails"
  gem "pry-byebug"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "faker"
  gem "mock_redis"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "lighthouse-matchers"
  gem "axe-matchers"
end
