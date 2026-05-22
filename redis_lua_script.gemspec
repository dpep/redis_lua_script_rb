require_relative "lib/redis_lua_script/version"

Gem::Specification.new do |s|
  s.name        = "redis_lua_script"
  s.version     = RedisLuaScript::VERSION
  s.authors     = ["Daniel Pepper"]
  s.summary     = "RedisLuaScript"
  s.description = "Redis Lua script optimization"
  s.homepage    = "https://github.com/dpep/redis_lua_script_rb"
  s.license     = "MIT"

  s.files       = Dir.glob("lib/**/*")
  s.test_files  = Dir.glob("spec/**/*_spec.rb")

  s.add_dependency "redis"

  s.add_development_dependency "benchmark-ips"
  s.add_development_dependency "byebug"
  s.add_development_dependency "codecov"
  s.add_development_dependency "redis-namespace"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
end
