module Gems
  def configure_gems
    # Gems
    # require_relative 'gemfile'
    # gemfile instructions
    gem 'pg', '~> 1.4.5'

    # development gems
    gem_group :development do
      gem 'bullet', '~> 7.0.4'
      gem 'memory_profiler'
    end

    # test gems
    gem_group :test do
      gem 'rspec-sonarqube-formatter', '~> 1.5', require: false
      gem 'shoulda-matchers', '~> 5.2.0'

      gem 'simplecov', require: false
      gem 'simplecov-json'

      gem 'simplecov-rcov'
      gem 'webdrivers'
    end

    # development and test gems
    gem_group :development, :test do
      gem 'database_cleaner'

      gem 'dotenv-rails'
      gem 'factory_bot_rails'

      gem 'faker', '~> 3.0.0'

      gem 'reek'
      gem 'rspec-rails', '~> 6.0.0'
      gem 'rswag-specs', '~> 2.8.0'
      gem 'rubocop'
      gem 'rubocop-rails', require: false
    end
  end
end
