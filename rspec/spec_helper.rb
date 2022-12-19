module Rspec
  def spec_helper_configurations
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
  end
end
