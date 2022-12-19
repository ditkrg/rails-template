# this file is used to generate rails app api template with some gems and configurations

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
  gem 'rubocop-rails', require: false
end

# rails_command('bundle install')
rails_command('generate rspec:install')

file 'spec/helpers.rb', <<~CODE
  module Helpers
    def transform_to_translation_attributes(attributes)
      translations_attributes = attributes.select { |attribute| attribute.end_with?('_en', '_ar', '_ckb') }
      return attributes if translations_attributes.blank?

      attributes = attributes.reject { |attr| translations_attributes.keys.include?(attr) }

      transformed = translations_attributes.map do |attribute, value|
        attribute_only_name = attribute.to_s.split('_')
        locale = attribute_only_name.pop

        new_hash = {}
        new_hash['locale'] = locale
        new_hash[attribute_only_name.join('_')] = value

        new_hash
      end
      { **attributes, translations_attributes: transformed.group_by do |attr|
                                                 attr['locale']
                                               end.map { |_locale, hashes| hashes.reduce({}, :merge) } }
    end

    def expect_response_to_be_serialized(response, serializer, **options)
      options = { include_associations: true } if options.blank?
      json_response = JSON.parse(response.body)

      attributes = serializer._attributes
      associations = serializer._reflections.keys
      attributes_to_match = attributes
      attributes_to_match += associations if options[:include_associations]
      attributes_to_match -= options[:associations_to_exclude] if options[:associations_to_exclude].present?

      if json_response.is_a?(Array)
        expect(json_response.map(&:keys).uniq.flatten.map(&:to_sym) || []).to match_array(attributes_to_match)
      else
        expect(json_response.keys.uniq.flatten.map(&:to_sym) || []).to match_array(attributes_to_match)
      end
    end

    def bypass_user(subject, user)
      subject.class.skip_before_action :authenticate! if subject._process_action_callbacks.map do |c|
        c.filter if c.kind == :before
      end.compact.include?(:authenticate!)

      abilities_and_user_object = {
        abilities: Ability.new(user),
        current_user: user
      }
      allow_any_instance_of(subject.class).to receive(:serialization_scope).and_return(abilities_and_user_object)
      allow_any_instance_of(subject.class).to receive(:current_user).and_return(abilities_and_user_object[:current_user])
      allow_any_instance_of(subject.class).to receive(:current_ability).and_return(abilities_and_user_object[:abilities])
    end

    def expect_workflow_validation_to_pass(resource:, transition_into:, invoker_event:, attributes_expected_to_be_required: [], attributes_not_expected_to_be_required: [])
      resource.workflower_initializer
      allowed_transitions = resource.allowed_transitions.map(&:transition_into)

      resource.send(invoker_event.to_s + '!')

      error_attributes = resource.errors&.attribute_names

      # Expect transitioning workflow to be part of the allowed transitions
      expect(allowed_transitions).to include(transition_into)

      attributes_expected_to_be_required.each do |attribute|
        expect(error_attributes).to include(attribute)
      end

      attributes_not_expected_to_be_required.each do |attribute|
        expect(error_attributes).not_to include(attribute)
      end

      # There should be no workflow error
      expect(error_attributes).not_to include(:workflow_state)

      # Expect workflow state to change to the transitioned one
      expect(resource.workflow_state).to eq(transition_into)

      selected_flow = resource.allowed_transitions.select { |flow| flow.event == invoker_event.to_s }&.last
      expect(resource.sequence).to eq(selected_flow&.downgrade_sequence&.negative? ? selected_flow&.sequence : selected_flow&.downgrade_sequence)
    end
  end

CODE

file 'spec/rails_helper.rb', <<~CODE

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  require 'spec_helper'
  require 'helpers'

  ENV['RAILS_ENV'] ||= 'test'
  require File.expand_path('../config/environment', __dir__)
  # Prevent database truncation if the environment is production
  abort('The Rails environment is running in production mode!') if Rails.env.production?
  require 'rspec/rails'
  # Add additional requires below this line. Rails is not loaded until this point!
  Dir[Rails.application.root + "/lib/swagger/*.rb"].each { |file| require file }

  # Requires supporting ruby files with custom matchers and macros, etc, in
  # spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
  # run as spec files by default. This means that files in spec/support that end
  # in _spec.rb will both be required and run as specs, causing the specs to be
  # run twice. It is recommended that you do not name files matching this glob to
  # end with _spec.rb. You can configure this pattern with the --pattern
  # option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
  #
  # The following line is provided for convenience purposes. It has the downside
  # of increasing the boot-up time by auto-requiring all files in the support
  # directory. Alternatively, in the individual `*_spec.rb` files, manually
  # require only the support files necessary.
  #
  # Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

  # Checks for pending migrations and applies them before tests are run.
  # If you are not using ActiveRecord, you can remove these lines.
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e
    puts e.to_s.strip
    exit 1
  end
  RSpec.configure do |config|
    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = ::Rails.root/spec/fixtures

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    # config.use_transactional_fixtures = true

    # The different available types are documented in the features, such as in
    # https://relishapp.com/rspec/rspec-rails/docs
    config.infer_spec_type_from_file_location!

    # Filter lines from Rails gems in backtraces.
    config.filter_rails_from_backtrace!

    config.include FactoryBot::Syntax::Methods
    config.include Helpers
    config.extend ContextBuilder
    config.include JsonapiWrapperForFactories
  end

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
CODE

file 'spec/spec_helper.rb', <<~CODE
  RSpec.configure do |config|
    config.expect_with :rspec do |expectations|
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    # rspec-mocks config goes here. You can use an alternate test double
    # library (such as bogus or mocha) by changing the `mock_with` option here.
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = true
    end

    # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
    # have no way to turn it off -- the option exists only for backwards
    # compatibility in RSpec 3). It causes shared context metadata to be
    # inherited by the metadata hash of host groups and examples, rather than
    # triggering implicit auto-inclusion in groups with matching metadata.
    config.shared_context_metadata_behavior = :apply_to_host_groups

    config.formatter = 'documentation'
    config.add_formatter('RspecSonarqubeFormatter', 'out/test-report.xml')

    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end
    config.before(:each) do
      DatabaseCleaner.strategy = :transaction
    end
    config.before(:each, js: true) do
      DatabaseCleaner.strategy = :truncation
    end
    config.before(:each) do
      DatabaseCleaner.start
    end
    config.after(:each) do
      DatabaseCleaner.clean
    end
    config.before(:all) do
      DatabaseCleaner.start
    end
    config.after(:all) do
      DatabaseCleaner.clean
    end
  end


CODE

# database.yml
file 'config/database.yml', <<~CODE

  # PostgreSQL. Versions 9.3 and up are supported.
  #
  # Install the pg driver:
  #   gem install pg
  # On macOS with Homebrew:
  #   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
  # On macOS with MacPorts:
  #   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config
  # On Windows:
  #   gem install pg
  #       Choose the win32 build.
  #       Install PostgreSQL and put its /bin directory on your path.
  #
  # Configure Using Gemfile
  # gem "pg"
  #
  default: &default
    adapter: postgresql
    encoding: unicode
    # For details on connection pooling, see Rails configuration guide
    # https://guides.rubyonrails.org/configuring.html#database-pooling
    host: <%= ENV.fetch("DATABASE__HOST") { "localhost" } %>
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    port: <%= ENV.fetch("DATABASE__PORT", 5432) %>
    username: <%= ENV.fetch("DATABASE__USERNAME") %>
    password: <%= ENV.fetch("DATABASE__PASSWORD") { "" } %>

  development:
    <<: *default
    database: <%= ENV.fetch("DATABASE__NAME") { "beas_api_development" } %>

  test:
    <<: *default
    database: beas_api_test

  production:
    <<: *default
    database: <%= ENV.fetch("DATABASE__NAME") { "beas_api_production" } %>

CODE

# Dockerfile
file 'Dockerfile', <<~CODE
  FROM ruby:3.1.3-alpine AS base

  RUN apk update &&  \
  apk --update -qq add \
  libpq-dev \
  git \
  libxrender \
  fontconfig \
  freetype \
  libx11 \
  musl \
  libssl1.1 \
  && apk add --virtual build-dependencies build-base

  COPY --from=ghcr.io/surnet/alpine-wkhtmltopdf:3.16.0-0.12.6-full /bin/wkhtmltopdf /usr/bin/wkhtmltopdf

  # Set an environment variable where the Rails app is installed to inside of Docker image
  ENV RAILS_ROOT /home/app/webapp
  RUN mkdir -p $RAILS_ROOT

  # Set working directory
  WORKDIR $RAILS_ROOT

  # Setting env up
  ENV RAILS_ENV='production'
  ENV RACK_ENV='production'

  RUN gem install bundler -v 2.3.26

  FROM base AS installation

  # Adding gems
  COPY Gemfile Gemfile
  COPY Gemfile.lock Gemfile.lock

  RUN bundle config --global jobs 40
  RUN bundle config --global retry 10
  RUN bundle config --local set path 'vendor/bundle'
  RUN bundle config --local set deployment true
  RUN bundle config --local set without 'development test'
  RUN bundle install

  # Adding project files
  FROM installation AS production

  RUN addgroup -g 1001 webapp && adduser webapp -u 1001 -D -G webapp

  COPY --chown=webapp:webapp . .


  RUN mkdir -p tmp/pids
  RUN touch tmp/pids/server.pid

  RUN chown -R webapp:webapp $RAILS_ROOT

  EXPOSE 3000
  USER webapp

  CMD [ "bundle", "exec" ]

CODE

# docker-compose.yml
file 'docker-compose.yml', <<~CODE
  version: '3.1'
  services:
    db:
      image: postgres
      environment:
        POSTGRES_USERNAME: postgres
        POSTGRES_PASSWORD: mysecretpassword
      ports:
        - 5432:5432
    minio:
      image: bitnami/minio:latest
      environment:
        - MINIO_ROOT_USER=admin123
        - MINIO_ROOT_PASSWORD=admin123
      ports:
        - 9000:9000
        - 9001:9001
    redis:
      image: 'bitnami/redis:latest'
      environment:
        - ALLOW_EMPTY_PASSWORD=yes
      ports:
        - "6379:6379"
    rabbitmq:
      image: rabbitmq:3-management-alpine
      # volumes:
      #   - ~/docker-configs/rabbitmq/etc/rabbitmq/enabled_plugins:/etc/rabbitmq/enabled_plugins
      ports:
          - 5672:5672
          - 15672:15672
CODE

# .env
file '.env', <<~CODE
  DATABASE__HOST=localhost
  DATABASE__USERNAME=postgres
  DATABASE__PASSWORD=mysecretpassword
  DATABASE__NAPME=beas_api_development
  DATABASE__PORT=5432

CODE

after_bundle do
  docker compose up(-d)
  rails db: create
end
