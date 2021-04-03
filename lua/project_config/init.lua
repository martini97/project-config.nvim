local plugin = {}

local utils = require('project_config.utils')
local trust = require('project_config.trust')

-- sources config if it exists, if it's changed since the last time
-- ask confirmation
function plugin.source_config()
  local config_file = utils.get_config_file()

  if not trust.should_trust(config_file) then return end

  trust.set_trust(config_file, true)

  vim.cmd("silent source " .. config_file:absolute())
end

-- edit project config, if file does not exists it will create it
function plugin.edit_config()
  local config_file = utils.get_config_file()

  if not config_file:exists() then
    config_file:write('" This is the config file for: ' .. vim.loop.cwd() ..
                        '\n\n', 'w')
  end

  vim.cmd("silent edit " .. config_file:absolute())
  vim.api.nvim_feedkeys('G', 'n', false)
end

-- marks the current config as untrusted
function plugin.untrust_config()
  local config_file = utils.get_config_file()

  if not config_file:exists() then return end

  trust.set_trust(config_file, false)
end

-- external function used by the preview window, will automatically trust the
-- current project config file and close the current window (should be the
-- preview window)
function plugin.trust_file()
  local config_file = utils.get_config_file()
  trust.set_trust(config_file, true)
  vim.cmd [[wincmd c]]
end

return plugin
