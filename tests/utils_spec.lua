local Path = require('plenary.path')
local stub = require('luassert.stub')
local match = require('luassert.match')

local utils = require('project_config.utils')

describe('utils', function ()
  describe('index_of', function ()
    it('returns index of value', function()
      local table = {"lorem", "ipsum", "dolor", "sit"}
      local value = "dolor"
      local index = 3

      assert.are.same(utils.index_of(table, value), index)
    end)

    it('returns nil if value not in table', function()
      local table = {"lorem", "ipsum", "dolor", "sit"}
      local value = "amet"
      local index = nil

      assert.are.same(utils.index_of(table, value), index)
    end)
  end)

  describe('sha256', function ()
    local sha_file = Path:new("tmp/test-sha256.txt")

    before_each(function ()
      sha_file:touch({ parents = true })
    end)

    after_each(function ()
      sha_file:rm()
    end)

    it('returns file sha256', function()
      sha_file:write("lorem ipsum dolor sit amet", "w")

      local sha = "2f8586076db2559d3e72a43c4ae8a1f5957abb23ca4a1f46e380dd640536eedb"
      assert.are.same(utils.sha256(sha_file), sha)
    end)

    it('changes if file changes', function()
      sha_file:write("lorem ipsum dolor sit amet", "w")
      local old_sha = utils.sha256(sha_file)

      sha_file:write("consectetur adipiscing elit", "a")
      local new_sha = utils.sha256(sha_file)

      assert.Not.are.same(old_sha, new_sha)
    end)

    it('returns nil if file does not exist', function()
      sha_file:rm()

      assert.are.same(utils.sha256(sha_file), nil)
    end)

    it('does not change if file updated but content did not changed', function()
      sha_file:write("lorem ipsum dolor sit amet", "w")
      local old_sha = utils.sha256(sha_file)

      sha_file:touch()
      local new_sha = utils.sha256(sha_file)

      assert.are.same(old_sha, new_sha)
    end)
  end)

  describe('confirm', function()
    local stubed_eval

    before_each(function()
      stubed_eval = stub(vim.api, "nvim_eval")
    end)

    after_each(function()
      stubed_eval:revert()
    end)

    it('call nvim_eval', function()
      utils.confirm("Dialog?", {"y", "n"}, "n")

      assert.stub(vim.api.nvim_eval).was.called(1)
      assert.stub(vim.api.nvim_eval).was.called_with(match.is_string())
      assert.stub(vim.api.nvim_eval).was.called_with(
        match.has_match('^confirm."Dialog.", "y\nn", "2".')
      )
    end)

    it('returns nvim_eval output', function()
      vim.api.nvim_eval.returns(2)
      local output = utils.confirm("Dialog?", {"y", "n"}, "n")

      assert.are.same(output, 2)
    end)
  end)

  describe('get_project_file', function()
    local project_file = Path:new('.test-get-project-file.vim')
    local old_project_config = vim.g.project_config_file

    before_each(function()
      vim.g.project_config_file = '.test-get-project-file.vim'
    end)

    after_each(function()
      vim.g.project_config_file = old_project_config
      project_file:rm()
    end)

    it('returns nil if file does not exists', function()
      assert.are.same(utils.get_project_file(), nil)
    end)

    it('returns absolute path to file if exists', function()
      project_file:touch()
      assert.are.same(utils.get_project_file(), project_file:absolute())
    end)
  end)
end)
