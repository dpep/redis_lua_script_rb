RedisLuaScript
======
![Gem](https://img.shields.io/gem/dt/redis_lua_script?style=plastic)
[![codecov](https://codecov.io/gh/dpep/redis_lua_script_rb/branch/main/graph/badge.svg)](https://codecov.io/gh/dpep/redis_lua_script_rb)

Run Redis Lua scripts with [EVALSHA](https://redis.io/commands/EVALSHA), so each call sends a 40 character SHA instead of the whole script, falling back to EVAL the first time a server hasn't seen it.

The win scales with script size and how slow the link is. Tiny scripts gain nothing; large ones gain a lot (`script/benchmark`, 100 Mbit/s, +1 ms latency):

| script size | EVAL | EVALSHA |
|---|---|---|
| 100 B | 1.38 ms | 1.38 ms |
| 1 KB | 1.47 ms | 1.38 ms |
| 10 KB | 2.31 ms | 1.37 ms |
| 100 KB | 10.3 ms | 1.44 ms |

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
