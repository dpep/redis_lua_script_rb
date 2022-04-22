require "redis_lua_script"

class RedisLuaScript
  module ImplicitRedis
    def eval(script, *args)
      rls = script.is_a?(RedisLuaScript) ? script : RedisLuaScript.new(script)

      evalsha(rls.sha, *args)
    rescue Redis::CommandError => e
      raise unless e.message.include?("NOSCRIPT")

      # fall back to regular eval, which will trigger
      # script to be cached for next time
      super(rls.send(:minify), *args)
    end
  end

  module ImplicitScript
    def eval(redis, *args)
      # pass through to avoid double instantiation
      redis.eval(self, *args)
    end
  end
end

Redis.prepend(RedisLuaScript::ImplicitRedis)
RedisLuaScript.prepend(RedisLuaScript::ImplicitScript)
