local Path = require('plenary.path')
local stub = require('luassert.stub')
local match = require("luassert.match")

local plugin = require 'project_config'
local cache = require 'project_config.cache'
local utils = require 'project_config.utils'
local window = require 'project_config.window'

local function is_same_path(_, args)
  local file = args[1]
	return function (value)
    return value:absolute() == file:absolute()
	end
end

assert:register("matcher", "same_path", is_same_path)

describe('project_config', function()
  local stubbed_confirm
  local stubbed_preview
  local cache_file = Path:new(vim.g.project_config_cache_file)
  local config_file = utils.get_config_file()

  before_each(function()
    vim.g.sourced = 0
    stubbed_confirm = stub(utils, 'confirm')
    stubbed_preview = stub(window, 'preview')
    config_file:touch({parents = true})
    config_file:write('let g:sourced = 1', 'w')
  end)

  after_each(function()
    vim.g.sourced = 0

    config_file:rm()
    cache_file:rm()
    stubbed_confirm:revert()
    stubbed_preview:revert()
  end)

  describe('source_config', function()
    it('sources config file if trusted', function()
      cache.set_cached(config_file:absolute(), utils.file_signature(config_file))

      plugin.source_config()

      assert.are.same(vim.g.sourced, 1)
    end)

    it('sources if user trust the file', function()
      stubbed_confirm.returns(1)
      plugin.source_config()

      assert.are.same(vim.g.sourced, 1)
    end)

    it('saves file to cache if trusted', function()
      stubbed_confirm.returns(1)
      assert.are.same(cache.get_cached()[config_file:absolute()], nil)

      plugin.source_config()

      assert.are.same(cache.get_cached()[config_file:absolute()],
                      utils.file_signature(config_file))
    end)

    it('asks for confirmation if not trusted', function()
      plugin.source_config()

      assert.stub(stubbed_confirm).was.called(1)
    end)

    it('does not source if user doesnt trust the file', function()
      stubbed_confirm.returns(2)
      plugin.source_config()

      assert.are.same(vim.g.sourced, 0)
    end)

    it('does not saves file to cache if not trusted', function()
      stubbed_confirm.returns(2)
      assert.are.same(cache.get_cached()[config_file:absolute()], nil)

      plugin.source_config()

      assert.are.same(cache.get_cached()[config_file:absolute()], nil)
    end)

    it('shows preview window if user asks to preview', function()
      stubbed_confirm.returns(3)
      plugin.source_config()

      assert.are.same(vim.g.sourced, 0)
      assert.stub(window.preview).was.called(1)
    end)
  end)

  describe('edit_config', function()
    it('creates file if it doesnt exist', function()
      config_file:rm()

      plugin.edit_config()

      local expected_header = '" This is the config file for: ' ..
                                vim.loop.cwd()
      assert.are.same(config_file:readlines()[1], expected_header)
    end)

    it('sends user to config file', function()
      plugin.edit_config()

      assert.are.same(vim.api.nvim_buf_get_name(0), config_file:absolute())
    end)
  end)

  describe('untrust_config', function()
    it('removes file from trusted', function()
      cache.set_cached(config_file:absolute(), utils.file_signature(config_file))

      plugin.untrust_config()

      assert.are.same(cache.get_cached()[config_file:absolute()], '')
    end)
  end)

  describe('trust_file', function()
    local stubbed_cmd
    local stubbed_source

    before_each(function()
      stubbed_cmd = stub(vim, 'cmd')
      stubbed_source = stub(utils, 'source')
    end)

    after_each(function()
      stubbed_cmd:revert()
      stubbed_source:revert()
    end)

    it('marks file as trusted', function()
      assert.are.same(cache.get_cached()[config_file:absolute()], nil)

      plugin.trust_file()

      assert.are.same(cache.get_cached()[config_file:absolute()],
                      utils.file_signature(config_file))
    end)

    it('sources file', function()
      plugin.trust_file()

      assert.stub(utils.source).was.called(1)
      assert.stub(utils.source).was.called_with(match.is_same_path(config_file))
    end)

    it('closes current window', function()
      plugin.trust_file()

      assert.stub(vim.cmd).was.called(1)
      assert.stub(vim.cmd).was.called_with("wincmd c")
    end)
  end)
end)
