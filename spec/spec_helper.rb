require "byebug"
require "redis-namespace"
require "rspec"
require "simplecov"

SimpleCov.start do
  add_filter /spec/
end

if ENV["CI"] == "true" || ENV["CODECOV_TOKEN"]
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

# load this gem
gem_name = Dir.glob("*.gemspec")[0].split(".")[0]
require gem_name

RSpec.configure do |config|
  # allow "fit" examples
  config.filter_run_when_matching :focus

  config.mock_with :rspec do |mocks|
    # verify existence of stubbed methods
    mocks.verify_partial_doubles = true
  end

  config.register_ordering :global do |examples|
    last, other = examples.partition do |example|
      example.metadata[:run_last]
    end

    other + last
  end
end

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
