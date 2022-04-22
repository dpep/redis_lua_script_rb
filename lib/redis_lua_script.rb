require "digest"
require "redis"
require "redis_lua_script/version"

class RedisLuaScript
  attr_reader :source

  def initialize(source)
    @source = source.dup.freeze
  end

  def sha
    @sha ||= Digest::SHA1.hexdigest(minify).freeze
  end

  def eval(redis, *args)
    redis.evalsha(sha, *args)
  rescue Redis::CommandError => e
    raise unless e.message.include?("NOSCRIPT")

    # fall back to regular eval, which will trigger
    # script to be cached for next time
    redis.eval(minify, *args)
  end

  def load(redis)
    unwrap_redis(redis).script(:load, minify).tap do |sha|
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

  def minify
    # trim comments (whole line and partial)
    # and whitespace (prefix and empty lines)
    @minify ||= source.gsub(/^\s*--.*\n|\s*--.*|^\s*|^$\n/, "").chomp.freeze
  end

  # Redis::Namespace deprecated script commands, so use raw redis connection
  def unwrap_redis(redis)
    defined?(Redis::Namespace) && redis.is_a?(Redis::Namespace) ? redis.redis : redis
  end
end
