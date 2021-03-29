local M = {}

local Path = require("plenary.path")
local cache = require('project_config.cache')
local utils = require('project_config.utils')

function M.has_trust(project_file)
  local cached = cache.get_cached()
  local sha = utils.sha256(project_file)
  return cached[project_file] == sha
end

function M.should_trust(project_file)
  if M.has_trust(project_file) then
    return true
  end

  local file = Path:new(project_file):normalize()
  local trust = utils.confirm(
    "Do you want to trust " .. file .. "?",
    {"yes", "no"},
    "no"
  )

  return trust == 1
end

function M.set_trust(project_file, trust)
  local sha = ''
  if trust then
    sha = utils.sha256(project_file)
  end

  local cached = cache.get_cached()
  cached[project_file] = sha
  cache.set_cached(cached)
end

return M
