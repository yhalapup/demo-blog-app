source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.4"

gem "activerecord-import", "~> 1.7", require: false
gem "bootsnap", require: false
gem "faker", "~> 3.0"
gem "importmap-rails"
gem "jbuilder"
gem "pg"
gem "puma", "~> 6.4", ">= 6.4.2"
gem "rails", "~> 7.0.8", ">= 7.0.8.3"
gem "sidekiq", "~> 7.2"
gem "smarter_csv", "~> 1.10", require: false
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "pry"
  gem "rubocop", "~> 1.58", require: false
  gem "rubocop-migration", "~> 0.4.2", require: false
  gem "rubocop-performance", "~> 1.19", require: false
  gem "rubocop-rails", "~> 2.22", require: false
end

group :development do
  gem "web-console"
end
