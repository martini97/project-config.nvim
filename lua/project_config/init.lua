local plugin = {}

local utils = require('project_config.utils')
local trust = require('project_config.trust')

function plugin.source_config()
  local config_file = utils.get_config_file()
  if not trust.should_trust(config_file) then return end

  trust.set_trust(config_file, true)

  vim.cmd("silent source " .. config_file:absolute())
end

function plugin.edit_config()
  local config_file = utils.get_config_file()

  if not config_file:exists() then
    config_file:write(
      '" This is the config file for: ' .. vim.loop.cwd() .. '\n\n', 'w'
    )
  end

  vim.cmd("silent edit " .. config_file:absolute())
  vim.api.nvim_feedkeys('G', 'n', false)
end

function plugin.untrust_config()
  local config_file = utils.get_config_file()

  if not config_file:exists() then
    return
  end

  trust.set_trust(config_file, false)
end

return plugin
