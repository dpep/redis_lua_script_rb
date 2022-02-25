require "redis/lua_script/implicit"

describe RedisLuaScript do
  before { redis.script(:flush) }
  after { subject }

  let(:redis) { Redis.new }
  let!(:script) { Redis::LuaScript.new("return redis.call('PING')") }

  it "prepends the Redis module" do
    expect(Redis.ancestors).to include(RedisLuaScript::ImplicitRedis)
  end

  describe "Redis#eval" do
    subject { redis.eval("return redis.call('PING')") }

    it { is_expected.to eq "PONG" }

    it "instantiates a RedisLuaScript implicitly" do
      expect(RedisLuaScript).to receive(:new).and_call_original
    end

    it "calls evalsha implicitly" do
      expect(redis).to receive(:evalsha)
    end

    context "when a RedisLuaScript is passed in" do
      subject { redis.eval(script) }

      it { is_expected.to eq "PONG" }

      it "reuses the RedisLuaScript" do
        expect(RedisLuaScript).not_to receive(:new)
      end

      it "it uses the RedisLuaScript methods" do
        expect(script).to receive(:sha).and_call_original
        expect(script).to receive(:minify).twice.and_call_original
      end
    end
  end

  describe "RedisLuaScript#eval" do
    subject { script.eval(redis) }

    it { is_expected.to eq "PONG" }

    it "reuses the RedisLuaScript object" do
      expect(RedisLuaScript).not_to receive(:new)
    end

    it "only calls evalsha once" do
      expect(redis).to receive(:evalsha)
    end

    it "only calls eval once" do
      expect(redis).to receive(:eval)
    end
  end
end
