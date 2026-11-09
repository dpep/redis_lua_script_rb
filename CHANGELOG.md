## Unreleased
- Requires Ruby 3.3 or newer.
- fix scripts running twice when their own error message contains "NOSCRIPT"
- stop minifying scripts, which broke valid Lua (`--` inside strings, block comments, long strings); `#sha` now equals the SHA Redis computes for the source
- implicit mode reuses one RedisLuaScript per script source instead of rebuilding it on every eval

###  v0.0.1  (2022-02-11)
- alpha release

