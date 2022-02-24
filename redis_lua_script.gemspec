package_name = Dir.glob("*.gemspec")[0].split(".")[0]
require "./lib/redis/lua_script/version"

package = Redis::LuaScript

Gem::Specification.new do |s|
  s.name        = package_name
  s.version     = package.const_get "VERSION"
  s.authors     = ["Daniel Pepper"]
  s.summary     = package.to_s
  s.description = "Redis Lua script optimization"
  s.homepage    = "https://github.com/dpep/redis_lua_script_rb"
  s.license     = "MIT"

  s.files       = Dir.glob("lib/**/*")
  s.test_files  = Dir.glob("spec/**/*_spec.rb")

  s.add_dependency "redis"

  s.add_development_dependency "byebug"
  s.add_development_dependency "codecov"
  s.add_development_dependency "redis-namespace"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
end
