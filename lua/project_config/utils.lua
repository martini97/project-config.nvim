local Path = require("plenary.path")

local utils = {}

-- calculate shasum for the string
function utils.sha256 (text)
  local cmd = string.format([[sha256('%s')]], text)
  return vim.api.nvim_eval(cmd)
end

-- calculate file signature, file should be instance of Path
function utils.file_signature (file)
  if not file:exists() then return nil end
  local content = string.format('%q', table.concat(file:readlines(), "\n"))
  return utils.sha256(content)
end

-- generate the config file for the current cwd
function utils.get_config_file ()
  local cwd = Path:new(vim.loop.cwd())
  local data_dir = Path:new(vim.fn.stdpath('data'))

  local file = utils.sha256(cwd:absolute()) .. ".vim"

  return data_dir:joinpath('project_config', file)
end

-- get index of value in table, or nil if missing
function utils.index_of (table, value)
  local index = {}
  for k,v in pairs(table) do
    index[v] = k
  end
  return index[value]
end

-- wrapper around vim confirm()
function utils.confirm (dialog, options, default)
  local opts = table.concat(options, "\n")
  local def = utils.index_of(options, default)
  return vim.api.nvim_eval(
    string.format(
      [[confirm("%s", "%s", "%s")]],
      dialog, opts, def
    )
  )
end

return utils
