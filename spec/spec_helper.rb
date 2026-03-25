# frozen_string_literal: true

require "bundler/setup"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
  config.warnings = true

  config.around do |example|
    $stdout = StringIO.new
    $stderr = StringIO.new
    example.run
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end
end
