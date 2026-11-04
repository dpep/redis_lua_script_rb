RedisLuaScript
======
![Gem](https://img.shields.io/gem/dt/redis_lua_script?style=plastic)
[![codecov](https://codecov.io/gh/dpep/redis_lua_script_rb/branch/main/graph/badge.svg)](https://codecov.io/gh/dpep/redis_lua_script_rb)

Run Redis Lua scripts with [EVALSHA](https://redis.io/commands/EVALSHA), so each call sends a 40 character SHA instead of the whole script, falling back to EVAL the first time a server hasn't seen it.

### When to use it
The win comes from not resending the script, so it scales with script size and shrinks as bandwidth grows. Per-call time from `script/benchmark` with +1 ms latency:

| script size | ~lines | 100 Mbit/s EVAL → EVALSHA | 1 Gbit/s EVAL → EVALSHA |
|---|---|---|---|
| 1 KB | ~25 | 1.47 → 1.38 ms | 1.41 → 1.40 ms |
| 10 KB | ~250 | 2.31 → 1.37 ms | 1.56 → 1.39 ms |
| 100 KB | ~2,500 | 10.3 → 1.44 ms | 2.99 → 1.44 ms |

Most Redis scripts (locks, rate limiters, queue operations) are a few dozen lines, around 1–2 KB, where this saves next to nothing: plain `redis.eval` is simpler. Reach for it when scripts run to hundreds of lines, the link is slow or metered, or call volume is high enough that the bytes add up.

----
### Usage
```ruby
require "redis_lua_script"

redis = Redis.new
script = RedisLuaScript.new("return redis.call('PING')")

script.eval(redis)
```


----
### Implicit Mode
Use Redis per usual, with optimizations implicitly performed on script evaluations.

```ruby
require "redis_lua_script/implicit"

redis = Redis.new
redis.eval("return redis.call('PING')")
```


----
### Benchmarking
`script/benchmark` compares EVAL with EVALSHA across script sizes, through [Toxiproxy](https://github.com/Shopify/toxiproxy) to throttle bandwidth and add latency, since localhost hides what bytes on the wire cost.

```sh
brew install toxiproxy
toxiproxy-server &
script/benchmark                                 # 1 Gbit/s, +1 ms
script/benchmark --bandwidth 100 --latency 5     # slower link
script/benchmark --sizes 500,5000 --direct       # loopback, no proxy
```


----
## Contributing

Yes please  :)

1. Fork it
1. Create your feature branch (`git checkout -b my-feature`)
1. Ensure the tests pass (`bundle exec rspec`)
1. Commit your changes (`git commit -am 'awesome new feature'`)
1. Push your branch (`git push origin my-feature`)
1. Create a Pull Request


----
