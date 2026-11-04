require "digest"
require "redis"
require "redis_lua_script/version"

class RedisLuaScript
  attr_reader :source

  # Redis's own cache-miss error; a script's error_reply can also contain "NOSCRIPT"
  def self.noscript?(error)
    error.message.start_with?("NOSCRIPT No matching script")
  end

  def initialize(source)
    @source = source.frozen? ? source : source.dup.freeze
  end

  def sha
    @sha ||= Digest::SHA1.hexdigest(source).freeze
  end

  def eval(redis, *args)
    redis.evalsha(sha, *args)
  rescue Redis::CommandError => e
    raise unless RedisLuaScript.noscript?(e)

    # fall back to regular eval, which will trigger
    # script to be cached for next time
    redis.eval(source, *args)
  end

  def load(redis)
    unwrap_redis(redis).script(:load, source).tap do |sha|
      unless sha == self.sha
        raise "unexpected script SHA: expected #{self.sha}, got #{sha}"
      end
    end
  end

  def loaded?(redis)
    unwrap_redis(redis).script(:exists, sha)
  end
  alias_method :exists?, :loaded?

  def to_s
    source
  end

  private

  # Redis::Namespace deprecated script commands, so use raw redis connection
  def unwrap_redis(redis)
    defined?(Redis::Namespace) && redis.is_a?(Redis::Namespace) ? redis.redis : redis
  end
end
