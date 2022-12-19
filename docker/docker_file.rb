module Docker
  def docker_configurations
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
      i

      CMD [ "bundle", "exec" ]

    CODE
  end
end
