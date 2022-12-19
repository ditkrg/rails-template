# this file is used to generate rails app api template with some gems and configurations

require_relative './gems/gem_files'
require_relative './rspec/rails_helper'
require_relative './rspec/spec_helper'
require_relative './rspec/helpers/base'
require_relative './rspec/helpers/jsonapi_wrapper_for_factories'
require_relative './rspec/helpers/swagger_errors'

require_relative './docker/docker_compose'
require_relative './docker/docker_file'
require_relative './config/database'
require_relative './envs/env'

SELF = Rails::Generators::AppGenerator
SELF.include Gems
SELF.include Rspec
SELF.include Rspec::Helpers
SELF.include Docker
SELF.include Config
SELF.include Envs

run 'bundle remove tzinfo-data'

configure_gems                                unless ARGV.include?('--skip-gems')
spec_helper_configurations                    unless ARGV.include?('--skip-spec_helper_configurations')
rails_helper_configurations                   unless ARGV.include?('--skip-rails_helper_configurations')
base_configurations                           unless ARGV.include?('--skip-base_configurations')
jsonapi_wrapper_for_factories_configurations  unless ARGV.include?('--skip-jsonapi_wrapper_for_factories_configurations')
swagger_errors_configurations                 unless ARGV.include?('--skip-swagger_errors_configurations')
docker_configurations                         unless ARGV.include?('--skip-docker_configurations')
docker_compose_configurations                 unless ARGV.include?('--skip-docker_compose_configurations')
database_configurations                       unless ARGV.include?('--skip-database_configurations')
dot_env_configurations                        unless ARGV.include?('--skip-dot-env-configurations')

rails_command('generate rspec:install')

