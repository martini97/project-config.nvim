local trust = {}
local utils = require('project_config.utils')
local cache = require('project_config.cache')
local window = require("project_config.window")

-- compares file signature with cache
function trust.is_trusted(file)
  local signature = utils.file_signature(file)
  if not signature or not file:exists() then return false end

  local cache_data = cache.get_cached()
  local cache_signature = cache_data[file:absolute()]

  if not cache_signature then return false end

  return cache_signature == signature
end

-- ask for user confirmation if should or not trust file
function trust.should_trust(file)
  if not file:exists() then return false end

  if trust.is_trusted(file) then return true end

  local trusted = utils.confirm("Do you want to trust " .. file:normalize() ..
                                  "?", {"yes", "No", "preview"}, "no")

  if trusted == 3 then
    window.preview(file)
    return false
  end

  return trusted == 1
end

-- sets file as trusted or not
function trust.set_trust(file, trusted)
  local signature = ''
  if trusted then signature = utils.file_signature(file) end

  cache.set_cached(file:absolute(), signature)
end

return trust
