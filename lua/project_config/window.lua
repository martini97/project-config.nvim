-- This will handle rendering the preview window
local window = {}
local Path = require('plenary.path')
local float = require('plenary.window.float')

local function wincmd(win_id, cmd)
    local winnr = vim.fn.win_id2win(win_id)
    return ("%dwincmd %s"):format(winnr, cmd)
end

-- TODO(martini97, 2021-04-03): allow user to override mappings
function window.preview(file)
    local project = Path:new(vim.loop.cwd())
    local message = {
        ("Previewing config file for: %s"):format(project:normalize()),
        "[<A-y>]: trust the file\t|\t[<A-n>]: don't trust and quit this window"
    }
    local win = float.centered_with_top_win(message, {winblend = 0})

    local close_cmd = ":" .. wincmd(win.win_id, "c") .. "<cr>"

    vim.api.nvim_buf_set_option(win.bufnr, "filetype", "vim")

    vim.api.nvim_buf_set_keymap(win.bufnr, "n", "<a-q>", close_cmd,
                                {noremap = true})

    vim.api.nvim_buf_set_keymap(win.bufnr, "n", "<a-y>",
                                [[:lua require"project_config".trust_file()<cr>]],
                                {noremap = true, silent = true})

    vim.api.nvim_buf_set_lines(win.bufnr, 0, -1, false, file:readlines())

    vim.defer_fn(function() vim.cmd(":" .. wincmd(win.win_id, "w")) end, 20)
end

return window
