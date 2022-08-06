#!/usr/bin/env ruby

require "benchmark/ips"
require "redis"
require "redis_lua_script"

# LUA = "return redis.call('PING')".freeze
LUA = "return 123".freeze


redis = Redis.new
script = RedisLuaScript.new(LUA)
script.load(redis)

# class Suite < Benchmark::IPS::NoopSuite
#   def running(*)
#     redis.script(:flush)
#   end
# end
  # x.config(suite: Suite.new)
  # x.config(time: 1, warmup: 0)

Benchmark.ips(time: 2, warmup: 0.01) do |x|
  x.report('Lua') do
    redis.eval(LUA)
  end

  x.report('RedisLuaScript') do
    RedisLuaScript.new(LUA).eval(redis)
  end

  x.report('RedisLuaScript static') do
    script.eval(redis)
  end
end
