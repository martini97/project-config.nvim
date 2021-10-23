local Path = require("plenary.path")
local sha = require("project_config.sha2")

local utils = {}

-- calculate file signature, file should be instance of Path
function utils.file_signature(file)
  if not file:exists() then
    return nil
  end
  local content = string.format("%q", table.concat(file:readlines(), "\n"))
  return sha.sha256(content)
end

-- generate the config file for the current cwd
function utils.get_config_file()
  local cwd = Path:new(vim.loop.cwd())
  local data_dir = Path:new(vim.fn.stdpath("data"))
  local file = sha.sha256(cwd:absolute()) .. ".vim"
  local config_file = data_dir:joinpath("project_config", file)
  if config_file:exists() then
    return config_file
  end

  for _, path in pairs(cwd:parents()) do
    local parent_config = data_dir:joinpath("project_config", sha.sha256(path) .. ".vim")
    if parent_config:exists() then
      return parent_config
    end
  end

  return config_file
end

-- get index of value in table, or nil if missing
function utils.index_of(table, value)
  local index = {}
  for k, v in pairs(table) do
    index[v] = k
  end
  return index[value]
end

-- wrapper around vim confirm()
function utils.confirm(dialog, options, default)
  local opts = table.concat(options, "\n")
  local def = utils.index_of(options, default)
  return vim.api.nvim_eval(string.format([[confirm("%s", "%s", "%s")]], dialog, opts, def))
end

-- source config file
function utils.source(file)
  vim.cmd(string.format("silent source %s", file:absolute()))
end

return utils
