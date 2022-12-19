module Docker
  def docker_compose_configurations
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
  end
end
