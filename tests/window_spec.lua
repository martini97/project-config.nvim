local Path = require 'plenary.path'
local stub = require 'luassert.stub'

local utils = require 'project_config.utils'
local window = require 'project_config.window'

local function get_rhs_by_lhs(keymaps, lhs)
  for _, value in pairs(keymaps) do
    if value["lhs"] == lhs then return value["rhs"] end
  end
  return nil
end

local function get_header()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
    if lines[1] == string.rep("=", 80) then return bufnr end
  end
  return nil
end

describe('window', function()
  local config_file
  local stubbed_get_config_file
  local stubbed_source

  before_each(function()
    local file_name = ("/tmp/%s-%d.txt"):format(os.time(os.date("!*t")),
                                                vim.loop.getpid())
    config_file = Path:new(file_name)
    stubbed_source = stub(utils, 'source')
    stubbed_get_config_file = stub(utils, 'get_config_file')
    stubbed_get_config_file.returns(config_file)
    config_file:touch({parents = true})
  end)

  after_each(function()
    config_file:rm()
    stubbed_get_config_file:revert()
    stubbed_source:revert()
  end)

  describe('preview', function()
    it('focus on window', function()
      local current_win_id = vim.fn.win_getid()
      config_file:write("test", "a")

      window.preview(config_file)

      assert.Not.are.same(current_win_id, vim.fn.win_getid())
    end)

    it('sets filetype', function()
      local bufnr = vim.fn.bufnr()
      local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
      assert.are.same(ft, 'vim')
    end)

    it('sets keymaps', function()
      window.preview(config_file)

      local win_id = vim.fn.win_getid()
      local winnr = vim.fn.win_id2win(win_id)
      local bufnr = vim.fn.bufnr()
      local keymaps = vim.api.nvim_buf_get_keymap(bufnr, "n")
      local expected_maps = {
        ["<M-n>"] = ":" .. winnr .. "wincmd c<CR>", -- close window
        ["<M-y>"] = [[:lua require"project_config".trust_file()<CR>]]
      }

      for lhs, rhs in pairs(expected_maps) do
        assert.are.same(rhs, get_rhs_by_lhs(keymaps, lhs))
      end
    end)

    it('loads file on preview window', function()
      local content = {"1st line", "2nd line"}
      config_file:write(table.concat(content, '\n'), "w")
      window.preview(config_file)

      local bufnr = vim.fn.bufnr() -- should be focused on text tab
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 3, false)
      assert.are.same(content, lines)
    end)

    it('renders header', function()
      window.preview(config_file)

      local header = get_header()

      local lines = vim.api.nvim_buf_get_lines(header, 1, 3, false)

      assert.is.truthy(
        string.match(lines[1], '^Previewing config file for: ~.*'))
      assert.is.truthy(lines[2],
                       [[[<A-y>]: trust the file\t|\t[<A-n>]: don't trust and quit this window]])
    end)

    -- TODO(martini97, 2021-04-03): this test fails, can't seem to properly
    -- trigger the keymap :(
    --[[ it('sources the config file', function()
      window.preview(config_file)
      vim.api.nvim_feedkeys('<a-y>', 'n', true)
      assert.stub(utils.source).was.called(1)
    end) ]]
  end)
end)
