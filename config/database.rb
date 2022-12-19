module Config
  def database_configurations
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
  end
end
