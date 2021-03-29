local M = {}

local Path = require("plenary.path")

function M.index_of(table, value)
  local index = {}
  for k,v in pairs(table) do
     index[v] = k
  end
  return index[value]
end

function M.sha256(file)
  local p = Path:new(file)

  if not p:exists() then return nil end

  local file_contents = table.concat(p:readlines(), "\n")
  return vim.api.nvim_eval('sha256("' .. file_contents .. '")')
end

function M.confirm(dialog, options, default)
  local opts = table.concat(options, "\n")
  local def = M.index_of(options, default)
  return vim.api.nvim_eval(
    string.format(
      [[confirm("%s", "%s", "%s")]],
      dialog, opts, def
    )
  )
end

function M.get_project_file()
  local cwd = Path:new(vim.loop.cwd())
  local project_file = cwd:joinpath(vim.g.project_config_file)

  if not project_file:exists() then
    return nil
  end

  return project_file:absolute()
end

return M
