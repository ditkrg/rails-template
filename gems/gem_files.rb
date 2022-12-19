module Gems
  def configure_gems
    # Gems
    # require_relative 'gemfile'
    # gemfile instructions
    gem 'pg', '~> 1.4.5'                        unless ARGV.include?('--skip-gem-pg')
    gem 'tzinfo-data'                           unless ARGV.include?('--skip-gem-tzinfo-data')
    gem 'bunny', '>= 2.19.0'                    unless ARGV.include?('--skip-gem-bunny')
    gem 'httparty'                              unless ARGV.include?('--skip-gem-httparty')
    gem 'rabbit_carrots', '~> 0.1.14'           unless ARGV.include?('--skip-gem-rabbit_carrots')
    gem 'redis', '~> 4.5'                       unless ARGV.include?('--skip-gem-redis')
    gem 'sentry-rails', '~> 5.6.0'              unless ARGV.include?('--skip-gem-sentry-rails')
    gem 'sentry-ruby', '~> 5.6.0'               unless ARGV.include?('--skip-gem-sentry-ruby')
    gem 'sidekiq', '>= 6.4.0', '< 7.0.0'        unless ARGV.include?('--skip-gem-sidekiq')
    gem 'sidekiq-cron', '~> 1.8.0'              unless ARGV.include?('--skip-gem-sidekiq-cron')

    # development gems
    gem_group :development do
      gem 'bullet', '~> 7.0.4'                  unless ARGV.include?('--skip-gem-bullet')
      gem 'memory_profiler'                     unless ARGV.include?('--skip-gem-memory_profiler')
    end

    # test gems
    gem_group :test do
      unless ARGV.include?('--skip-gem-rspec-sonarqube-formatter')
        gem 'rspec-sonarqube-formatter', '~> 1.5',
            require: false
      end
      gem 'shoulda-matchers', '~> 5.2.0'                        unless ARGV.include?('--skip-gem-shoulda-matchers')

      gem 'simplecov', require: false                           unless ARGV.include?('--skip-gem-simplecov')
      gem 'simplecov-json'                                      unless ARGV.include?('--skip-gem-simplecov-json')

      gem 'simplecov-rcov'                                      unless ARGV.include?('--skip-gem-simplecov-rcov')
      gem 'webdrivers'                                          unless ARGV.include?('--skip-gem-webdrivers')
    end

    # development and test gems
    gem_group :development, :test do
      gem 'database_cleaner'                                    unless ARGV.include?('--skip-gem-database_cleaner')

      gem 'dotenv-rails'                                        unless ARGV.include?('--skip-gem-dotenv-rails')
      gem 'factory_bot_rails'                                   unless ARGV.include?('--skip-gem-factory_bot_rails')

      gem 'faker', '~> 3.0.0'                                   unless ARGV.include?('--skip-gem-faker')

      gem 'reek'                                                unless ARGV.include?('--skip-gem-reek')
      gem 'rspec-rails', '~> 6.0.0'                             unless ARGV.include?('--skip-gem-rspec-rails')
      gem 'rswag-specs', '~> 2.8.0'                             unless ARGV.include?('--skip-gem-rswag-specs')
      gem 'rubocop'                                             unless ARGV.include?('--skip-gem-rubocop')
      gem 'rubocop-rails', require: false                       unless ARGV.include?('--skip-gem-rubocop-rails')
    end
  end
end
