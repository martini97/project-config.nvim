local trust = require('project_config.trust')
local utils = require('project_config.utils')
local cache = require('project_config.cache')
local window = require('project_config.window')
local Path = require('plenary.path')
local stub = require('luassert.stub')

describe('trust', function()
  local cache_file = Path:new(vim.g.project_config_cache_file)
  local file = Path:new('/tmp/test-trust' .. vim.loop.getpid() .. '.txt')
  local stubbed_preview
  local stubbed_confirm

  before_each(function()
    stubbed_preview = stub(window, 'preview')
    stubbed_confirm = stub(utils, 'confirm')
  end)

  after_each(function()
    cache_file:rm()
    file:rm()
    stubbed_preview:revert()
    stubbed_confirm:revert()
  end)

  describe('is_trusted', function()
    it('returns false if file missing', function()
      cache_file:rm()

      assert.Not.is.True(trust.is_trusted(file))
    end)

    it('returns true signature in file matches file', function()
      file:write('lorem ipsum', 'w')
      local signature = utils.file_signature(file)
      cache.set_cached(file:absolute(), signature)

      assert.is.True(trust.is_trusted(file))
    end)
  end)

  describe('should_trust', function()
    it('returns true if file already trusted', function()
      file:write('lorem ipsum', 'w')
      cache.set_cached(file:absolute(), utils.file_signature(file))

      assert.is.True(trust.should_trust(file))
    end)

    it('calls confirm', function()
      file:touch()

      trust.should_trust(file)

      assert.stub(utils.confirm).was.called(1)
      assert.stub(utils.confirm).was.called_with(
        "Do you want to trust " .. file:normalize() .. "?",
        {"yes", "No", "preview"}, "no")
    end)

    it('returns true if user answered "y"', function()
      file:touch()
      stubbed_confirm.returns(1)

      assert.is.True(trust.should_trust(file))
    end)

    it('returns false if user answered "f"', function()
      stubbed_confirm.returns(2)

      assert.Not.is.True(trust.should_trust(file))
    end)

    it('returns false if file missing', function()
      stubbed_confirm.returns(1)
      file:rm()

      assert.Not.is.True(trust.should_trust(file))
    end)

    it('returns false if user answered "p"', function()
      file:touch()
      stubbed_confirm.returns(3)

      assert.is.False(trust.should_trust(file))
    end)

    it('calls preview if user answered "p"', function()
      file:touch()
      stubbed_confirm.returns(3)

      trust.should_trust(file)

      assert.stub(window.preview).was.called(1)
    end)
  end)

  describe('set_trust', function()
    it('sets the trust for file', function()
      file:write('lorem ipsum', 'w')

      assert.Not.is.True(trust.is_trusted(file))

      trust.set_trust(file, true)

      assert.is.True(trust.is_trusted(file))

      trust.set_trust(file, false)

      assert.Not.is.True(trust.is_trusted(file))
    end)
  end)
end)
