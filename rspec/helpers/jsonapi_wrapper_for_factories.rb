module Rspec
  module Helpers
    def jsonapi_wrapper_for_factories_configurations
      file 'spec/helpers/swagger_errors.rb', <<~CODE
        module Helpers
        module JsonapiWrapperForFactories
          def wrap_factory_with_jsonapi(factory)
            attributes = factory.instance_of?(Hash) ? factory : factory.attributes
            {
              data: {
                id: factory.try(:id) || '',
                attributes: attributes.deep_transform_keys { |key| key&.to_s&.camelize :lower }
              },
              jsonapi: {
                version: '1.0'
              }
            }
          end
        end
        end
      CODE
    end
  end
end
