module Rspec
  module Helpers
    def swagger_errors_configurations
      file 'spec/helpers/swagger_errors.rb', <<~CODE
        module Helpers
          module SwaggerErrors
            def generate_swagger_error_responses(errors: {})
              if errors.with_indifferent_access.keys.include? '400'
                response(400, 'bad_request') do
                  errors.with_indifferent_access['400'].call
                  schema({ '$ref' => '#/components/schemas/BadRequest' })
                  run_test!
                end
              end

              if errors.with_indifferent_access.keys.include? '401'
                response(401, 'unauthorized') do
                  errors.with_indifferent_access['401'].call
                  schema({ '$ref' => '#/components/schemas/Unauthorized' })
                  run_test!
                end
              end

              if errors.with_indifferent_access.keys.include? '403'
                response(403, 'forbidden') do
                  errors.with_indifferent_access['403'].call
                  schema({ '$ref' => '#/components/schemas/Forbidden' })
                  run_test!
                end
              end

              if errors.with_indifferent_access.keys.include? '404'
                response(404, 'not_found') do
                  errors.with_indifferent_access['404'].call
                  schema({ '$ref' => '#/components/schemas/NotFound' })
                  run_test!
                end
              end

              if errors.with_indifferent_access.keys.include? '409'
                response(409, 'conflict') do
                  errors.with_indifferent_access['409'].call
                  schema({ '$ref' => '#/components/schemas/Conflict' })
                  run_test!
                end
              end

              if errors.with_indifferent_access.keys.include? '412'
                response(412, 'precondition_failed') do
                  errors.with_indifferent_access['412'].call
                  schema({ '$ref' => '#/components/schemas/PreconditionFailed' })
                  run_test!
                end
              end

              if errors.with_indifferent_access.keys.include? '422'
                response(422, 'unprocessable_entity') do
                  errors.with_indifferent_access['422'].call
                  schema({ '$ref' => '#/components/schemas/UnprocessableEntity' })
                  run_test!
                end
              end

              if errors.with_indifferent_access.keys.include? '500'
                response(500, 'internal_server_error') do
                  errors.with_indifferent_access['500'].call
                  schema({ '$ref' => '#/components/schemas/InternalServerError' })
                  run_test!
                end
              end
            end
          end

          def unbypass_user(subject, is_rswag: false)
            subject_class = subject
            subject_class = subject.class unless is_rswag
            subject_class.before_action :authenticate! unless subject_class._process_action_callbacks.map do |c|
              c.filter if c.kind == :before
            end.compact.include?(:authenticate!)

            allow_any_instance_of(subject_class).to receive(:current_user).and_return(nil)
            allow_any_instance_of(subject_class).to receive(:current_ability).and_return(nil)
          end
        end
      CODE
    end
  end
end
