describe RedisLuaScript do
  subject { RedisLuaScript.new(script) }
  let(:script) { "return redis.call('PING')" }

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
        expect { script.eval(redis) }.to raise_error(Redis::CommandError, /nonexistent global variable .foo./)
      end

      it "raises an error even when cached" do
        script.load(redis)
        expect(redis).not_to receive(:eval)
        expect { script.eval(redis) }.to raise_error(Redis::CommandError, /nonexistent global variable .foo./)
      end
    end

    context "when the script's own error mentions NOSCRIPT" do
      let(:script) do
        RedisLuaScript.new(%q{redis.call("INCR", KEYS[1]) return redis.error_reply("NOSCRIPT fake")})
      end

      before { redis.del("counter") }

      it "does not run the script again" do
        script.load(redis)
        expect { script.eval(redis, ["counter"]) }.to raise_error(Redis::CommandError, /NOSCRIPT fake/)
        expect(redis.get("counter")).to eq "1"
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

  describe "#source" do
    subject { RedisLuaScript.new(script).source }

    it "dups and freezes the script" do
      is_expected.not_to be script
      is_expected.to be_frozen
    end

    context "when script is already frozen" do
      let(:script) { "return redis.call('PING')".freeze }

      it "uses pre-frozen script" do
        is_expected.to be script
      end
    end
  end

  describe "#to_s" do
    it { expect(subject.to_s).to be subject.source }
  end

  describe "#sha" do
    it "matches the SHA Redis computes" do
      expect(subject.sha).to eq redis.script(:load, script)
    end
  end

  describe "script source" do
    shared_examples "runs verbatim" do |expected|
      it "matches plain EVAL" do
        expect(redis.eval(lua)).to eq expected
      end

      it "evals" do
        expect(RedisLuaScript.new(lua).eval(redis)).to eq expected
      end

      it "evals once cached" do
        RedisLuaScript.new(lua).load(redis)
        expect(RedisLuaScript.new(lua).eval(redis)).to eq expected
      end
    end

    context "with -- inside a string" do
      let(:lua) { %q{return "a--b"} }

      it_behaves_like "runs verbatim", "a--b"
    end

    context "with a block comment" do
      let(:lua) { "--[[ multi\nline comment ]]\nreturn 1" }

      it_behaves_like "runs verbatim", 1
    end

    context "with an indented long string" do
      let(:lua) { "return [[\n  indented\n\n  text]]" }

      it_behaves_like "runs verbatim", "  indented\n\n  text"
    end

    context "with args" do
      let(:script) do <<~LUA
          -- comments are kept
          local val = tonumber(ARGV[1])
          if val > 123 then
            return val
          end

          return 123
        LUA
      end

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
