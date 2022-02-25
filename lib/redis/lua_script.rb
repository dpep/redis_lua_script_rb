# inject into Redis namespace, ie. Redis::LuaScript

require "redis_lua_script"

class Redis
  LuaScript = RedisLuaScript
end
