local M = {}

local Path = require("plenary.path")

function M.set_cached(value)
  local p = Path:new(vim.g.project_config_cache_file)
  p:write(vim.fn.json_encode(value), "w")
end

function M.get_cached()
  local p = Path:new(vim.g.project_config_cache_file)
  local touched = p:touch({ parents = true })

  if touched then
    p:write("{}", "w")
    return vim.empty_dict()
  end

  return vim.fn.json_decode(p:readlines())
end

return M
