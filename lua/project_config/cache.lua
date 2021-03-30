local cache = {}

local Path = require("plenary.path")

local function get_cache_file ()
	return Path:new(vim.g.project_config_cache_file)
end

--- read and parse cache file
function cache.get_cached()
  local cache_file = get_cache_file()
  local touched = cache_file:touch({ parents = true })

  if touched then
    cache_file:write("{}", "w")
    return vim.empty_dict()
  end

  return vim.fn.json_decode(cache_file:readlines())
end

--- set key on cache file
function cache.set_cached(key, value)
  local cache_file = get_cache_file()
  local data = cache.get_cached()
  data[key] = value
  cache_file:write(vim.fn.json_encode(data), "w")
end

return cache
