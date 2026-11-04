require "redis_lua_script"

class RedisLuaScript
  module ImplicitRedis
    # reuse one RedisLuaScript per source, so the SHA isn't recomputed each call
    SCRIPTS = {}
    # bounds memory when scripts are generated dynamically
    MAX_SCRIPTS = 1_000

    def self.script_for(source)
      SCRIPTS.fetch(source) do
        SCRIPTS.clear if SCRIPTS.size >= MAX_SCRIPTS
        SCRIPTS[source] = RedisLuaScript.new(source)
      end
    end

    def eval(script, *args)
      rls = script.is_a?(RedisLuaScript) ? script : ImplicitRedis.script_for(script)

      evalsha(rls.sha, *args)
    rescue Redis::CommandError => e
      raise unless RedisLuaScript.noscript?(e)

      # fall back to regular eval, which will trigger
      # script to be cached for next time
      super(rls.source, *args)
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
