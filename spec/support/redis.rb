RSpec.shared_context "redis" do
  let(:redis) { Redis.new }
end

RSpec.configure do |config|
  config.include_context "redis"

  config.before do
    (redis.is_a?(Redis::Namespace) ? redis.redis : redis).tap do |redis|
      redis.script(:flush)
    end
  end
end
