describe RedisLuaScript, :run_last do
  before do
    require "redis_lua_script/implicit"
    redis.script(:flush)
  end
  after { subject }

  let!(:script) { RedisLuaScript.new("return redis.call('PING')") }

  describe Redis do
    it "prepends the Redis module" do
      expect(Redis.ancestors).to include(RedisLuaScript::ImplicitRedis)
    end
  end

  describe "Redis#eval" do
    subject { redis.eval(script.source) }

    it { is_expected.to eq "PONG" }

    it "instantiates a RedisLuaScript implicitly" do
      expect(RedisLuaScript).to receive(:new).with(script.source).and_call_original
    end

    it "calls evalsha implicitly" do
      expect(redis).to receive(:evalsha).with(script.sha)
    end

    context "when a RedisLuaScript is passed in" do
      subject { redis.eval(script) }

      it { is_expected.to eq "PONG" }

      it "reuses the RedisLuaScript" do
        expect(RedisLuaScript).not_to receive(:new)
      end

      it "it uses the RedisLuaScript methods" do
        expect(script).to receive(:sha).and_call_original
      end
    end

    context "when args are passed in" do
      subject { redis.eval("return { KEYS[1], ARGV[1] }", [ "key" ], [ 123 ]) }

      it "returns the arg" do
        is_expected.to eq [ "key", "123" ]
      end
    end
  end

  describe "RedisLuaScript#eval" do
    subject { script.eval(redis) }

    it { is_expected.to eq "PONG" }

    it "reuses the RedisLuaScript object" do
      expect(RedisLuaScript).not_to receive(:new)
      expect(script).to receive(:sha).and_call_original
    end

    it "only calls evalsha once" do
      expect(redis).to receive(:evalsha)
    end

    it "only calls eval once" do
      expect(redis).to receive(:eval)
    end
  end
end
