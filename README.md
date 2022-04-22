redis_lua_script
======
Optimize Redis Lua scripts through minification and [evalsha](https://redis.io/commands/EVALSHA).


```ruby
require "redis_lua_script"

redis = Redis.new
script = RedisLuaScript.new("return redis.call('PING')")

script.eval(redis)
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
![Gem](https://img.shields.io/gem/dt/redis_lua_script?style=plastic)
[![codecov](https://codecov.io/gh/dpep/redis_lua_script_rb/branch/main/graph/badge.svg)](https://codecov.io/gh/dpep/redis_lua_script_rb)
