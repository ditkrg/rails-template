module Rspec
  module Helpers
    def rspec_base_configurations
      file 'spec/helpers/base.rb', <<~CODE
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
    end
  end
end
