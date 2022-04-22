describe RedisLuaScript do
  subject { RedisLuaScript.new("return redis.call('PING')") }

  before { redis.script(:flush) }

  let(:redis) { Redis.new }

  it { is_expected.to be_a RedisLuaScript }

  describe "#eval" do
    def ping
      expect(subject.eval(redis)).to eq "PONG"
    end

    it { ping }

    it "loads the script into redis" do
      expect(redis).to receive(:evalsha).once.and_call_original
      expect(redis).to receive(:eval).once.and_call_original
      ping
      expect(subject.loaded?(redis)).to be true
    end

    context "when there is a legit script error" do
      let(:script) { RedisLuaScript.new("return foo") }

      it "raises an error" do
        expect(redis).to receive(:eval).and_call_original
        expect { script.eval(redis) }.to raise_error(Redis::CommandError, /Error running script/)
      end

      it "raises an error even when cached" do
        script.load(redis)
        expect(redis).not_to receive(:eval)
        expect { script.eval(redis) }.to raise_error(Redis::CommandError, /Error running script/)
      end
    end
  end

  describe "#load" do
    it "loads script into redis" do
      expect(redis.script(:exists, subject.sha)).to be false
      subject.load(redis)
      expect(redis.script(:exists, subject.sha)).to be true
    end

    it "returns the sha" do
      expect(subject.load(redis)).to eq subject.sha
    end

    it "validates the returned sha" do
      allow(redis).to receive(:script).with(:flush).and_call_original
      expect(redis).to receive(:script).with(:load, String).and_return("abc")
      expect { subject.load(redis) }.to raise_error(RuntimeError)
    end
  end

  describe "#loaded?" do
    it do
      expect(subject.loaded?(redis)).to be false
      subject.load(redis)
      expect(subject.loaded?(redis)).to be true
    end
  end

  describe "#exists?" do
    it 'works the same as .loaded?' do
      expect(subject.exists?(redis)).to be false
      subject.load(redis)
      expect(subject.exists?(redis)).to be true
    end
  end

  describe "#to_s" do
    it { expect(subject.to_s).to be subject.source }
  end

  describe "#minify" do
    subject { RedisLuaScript.new(lua) }

    shared_examples "minified lua" do
      it do
        expect(subject.send(:minify)).to eq expected
      end
    end

    context do
      let(:lua) do <<-LUA
          -- this comment gets removed
          return redis.call('PING')  -- this one too
        LUA
      end

      let(:expected) { "return redis.call('PING')" }

      it_behaves_like "minified lua"

      it "executes properly" do
        expect(subject.eval(redis)).to eq "PONG"
      end
    end

    context "with if statement" do
      let(:lua) do <<~LUA
          local val = tonumber(ARGV[1])
          if val > 123 then
            return val
          end

          return 123
        LUA
      end

      let(:expected) do
        [
          "local val = tonumber(ARGV[1])",
          "if val > 123 then",
          "return val",
          "end",
          "return 123",
        ].join "\n"
      end

      it_behaves_like "minified lua"

      it "executes properly" do
        expect(subject.eval(redis, [], [ 0 ])).to eq 123
        expect(subject.eval(redis, [], [ 999 ])).to eq 999
      end
    end
  end

  describe Redis do
    it "has not yet been altered" do
      expect(defined?(RedisLuaScript::ImplicitRedis)).to be nil
    end
  end
end
