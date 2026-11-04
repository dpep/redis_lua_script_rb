describe RedisLuaScript do
  subject { RedisLuaScript.new("return redis.call('PING')") }

  let(:redis) { Redis::Namespace.new(:ns, redis: Redis.new) }

  describe "#eval" do
    it "loads the script into redis" do
      expect(subject.loaded?(redis)).to be false
      expect(subject.eval(redis)).to eq "PONG"
      expect(subject.loaded?(redis)).to be true
    end
  end

  describe "#load" do
    it "loads script into redis" do
      expect(subject.loaded?(redis)).to be false
      subject.load(redis)
      expect(subject.loaded?(redis)).to be true
    end
  end
end
