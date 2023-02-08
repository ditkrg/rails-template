module Envs
  def dot_env_configurations
    file '.env', <<~CODE
      DATABASE__HOST=localhost
      DATABASE__USERNAME=postgres
      DATABASE__PASSWORD=mysecretpassword
      DATABASE__NAME=YOUR_DATABASE_NAME_api_development
      DATABASE__PORT=5432
    CODE
  end
end
