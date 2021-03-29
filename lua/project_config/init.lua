local M = {}

local utils = require('project_config.utils')
local trust = require('project_config.trust')

function M.source_settings()
  local project_file = utils.get_project_file()

  if not project_file then return end
  if not trust.should_trust(project_file) then return end

  trust.set_trust(project_file, true)

  vim.cmd("silent source " .. project_file)
end

function M.untrust()
  local project_file = utils.get_project_file()

  if not project_file then return end
  if not trust.has_trust(project_file) then return end

  trust.set_trust(project_file, false)
end

return M
