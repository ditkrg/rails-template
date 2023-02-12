module Gems
  def configure_gems
    # gemfile instructions
    run 'bundle add pg'                         unless ARGV.include?('--skip-gem-pg')
    run 'bundle add tzinfo-data'                unless ARGV.include?('--skip-gem-tzinfo-data')
    run 'bundle add bunny'                      unless ARGV.include?('--skip-gem-bunny')
    run 'bundle add httparty'                   unless ARGV.include?('--skip-gem-httparty')
    run 'bundle add rabbit_carrots'             unless ARGV.include?('--skip-gem-rabbit_carrots')
    run 'bundle add redis'                      unless ARGV.include?('--skip-gem-redis')
    run 'bundle add sentry-rails'               unless ARGV.include?('--skip-gem-sentry-rails')
    run 'bundle add sentry-ruby'                unless ARGV.include?('--skip-gem-sentry-ruby')
    run 'bundle add sidekiq'                    unless ARGV.include?('--skip-gem-sidekiq')

    run 'bundle add sidekiq-cron'               unless ARGV.include?('--skip-gem-sidekiq-cron')

    # development gems
    run 'bundle add bullet --group development' unless ARGV.include?('--skip-gem-bullet')
    # test gems
    run 'bundle add shoulda-matchers --group test'             unless ARGV.include?('--skip-gem-shoulda-matchers')
    run 'bundle add simplecov --group test'                    unless ARGV.include?('--skip-gem-simplecov')
    run 'bundle add simplecov-json --group test'               unless ARGV.include?('--skip-gem-simplecov-json')
    run 'bundle add simplecov-rcov --group test'               unless ARGV.include?('--skip-gem-simplecov-rcov')
    # development and test gems
    # gem 'database_cleaner'                                    unless ARGV.include?('--skip-gem-database_cleaner')
    run 'bundle add dotenv-rails --group development,test'      unless ARGV.include?('--skip-gem-dotenv-rails')

    run 'bundle add factory_bot_rails --group development,test' unless ARGV.include?('--skip-gem-factory_bot_rails')
    run 'bundle add faker --group development,test'             unless ARGV.include?('--skip-gem-faker')

    run 'bundle add rspec-rails --group development,test'       unless ARGV.include?('--skip-gem-rspec-rails')
    run 'bundle add rswag-specs --group development,test'       unless ARGV.include?('--skip-gem-rswag-specs')
    run 'bundle add rubocop --group development,test'           unless ARGV.include?('--skip-gem-rubocop')
    run 'bundle add rubocop-rails --group development,test'     unless ARGV.include?('--skip-gem-rubocop-rails')
  end
end
