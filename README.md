## DIT RUBY TEMPLATE
This is a template for a Rails project.

## Instructions
1. create a new rails app with the template flag like below:
```
rails new --api your_app_name --template https://github.com/ditkrg/rails-template/blob/main/template.rb

```

## Arguments
This template by default will create a new rails app with the following:
- postgresql
- rspec
- gemset
- dotenv
- docker
- docker-compose

* if you want to skip any of the above, you can pass the following arguments:
```
- postgres:             --skip-postgres
- rspec:                --skip-rspec
- gemset:               --skip-gemset
- dotenv:               --skip-dotenv
- docker:               --skip-docker
- docker-compose:       --skip-docker-compose
```
