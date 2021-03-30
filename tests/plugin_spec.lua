local Path = require('plenary.path')
local stub = require('luassert.stub')

local plugin = require('project_config')
local utils = require('project_config.utils')
local trust = require('project_config.trust')

describe('project_config', function ()
  local old_project_config = vim.g.project_config_file
  local cache_file = Path:new(vim.g.project_config_cache_file)
  local config_file = Path:new('.test-get-project-file.vim')
  local vim_cmd_stub
  local should_trust_stub
  local set_trust_stub
  local has_trust_stub

  before_each(function ()
    vim.g.project_config_file = '.test-get-project-file.vim'
    config_file:write('set number', "w")

    vim_cmd_stub = stub(vim, 'cmd')
    should_trust_stub = stub(trust, 'should_trust')
    set_trust_stub = stub(trust, 'set_trust')
    has_trust_stub = stub(trust, 'has_trust')
  end)

  after_each(function ()
    cache_file:rm()
    config_file:rm()
    vim_cmd_stub:revert()
    should_trust_stub:revert()
    set_trust_stub:revert()
    has_trust_stub:revert()
    vim.g.project_config_file = old_project_config
  end)

  describe('source_config', function ()
    it('does not source config if project file does not exist', function ()
      config_file:rm()

      plugin.source_config()

      assert.stub(vim.cmd).was.called(0)
    end)

    it('does not source config if user does not trust file', function ()
      should_trust_stub.returns(false)

      plugin.source_config()

      assert.stub(vim.cmd).was.called(0)
    end)

    it('set file as trusted if user trusts file', function ()
      should_trust_stub.returns(true)

      plugin.source_config()

      assert.stub(trust.set_trust).was.called(1)
      -- assert.stub(trust.set_trust).was.called_with(config_file, true)
    end)

    it('source file if is trusted', function ()
      should_trust_stub.returns(true)

      plugin.source_config()

      assert.stub(vim.cmd).was.called(1)
      -- assert.stub(vim.cmd).was.called_with(
      --   "silent source " .. config_file:absolute()
      -- )
    end)
  end)

  describe('untrust_config', function ()
    -- it('does nothing if file doenst exist', function ()
    --   has_trust_stub.returns(true)
    --   config_file:rm()

    --   plugin.untrust_config()

    --   assert.stub(trust.set_trust).was.called(0)
    -- end)

    -- it('doesnt set trust if file already not trusted', function ()
    --   has_trust_stub.returns(false)

    --   plugin.untrust_config()

    --   assert.stub(trust.set_trust).was.called(0)
    -- end)

    it('removes trust', function ()
      has_trust_stub.returns(true)

      plugin.untrust_config()

      assert.stub(trust.set_trust).was.called(1)
      -- assert.stub(trust.set_trust).was.called_with(config_file, false)
    end)
  end)
end)
