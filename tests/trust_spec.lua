local Path = require('plenary.path')
local stub = require('luassert.stub')

local trust = require('project_config.trust')
local utils = require('project_config.utils')
local cache = require('project_config.cache')

describe('trust', function ()
  local cache_file = Path:new(vim.g.project_config_cache_file)
  local file = Path:new("tmp/test-has-trust.txt")

  before_each(function ()
    file:write("lorem ipsum dolor sit amet", "w")
  end)

  after_each(function ()
    cache_file:rm()
    file:rm()
  end)

  describe('has_trust', function ()
    it('returns nil if file does not exist', function()
      assert.are.same(trust.has_trust("~/does/not/exist.txt"), nil)
    end)

    it('returns true if file in cache', function()
      cache.set_cached({
        [file:absolute()] = utils.sha256(file:absolute())
      })

      assert.is.True(trust.has_trust(file:absolute()))
    end)

    it('returns false if cache file does not exist', function()
      cache_file:rm()

      assert.Not.is.True(trust.has_trust(file:absolute()))
    end)

    it('returns false if file not in cache', function()
      cache.set_cached(vim.empty_dict())

      assert.Not.is.True(trust.has_trust(file:absolute()))
    end)

    it('returns false if file in cache but sha changed', function()
      cache.set_cached({
        [file:absolute()] = utils.sha256(file:absolute())
      })

      assert.is.True(trust.has_trust(file:absolute()))

      file:write("consectetur adipiscing elit", "a")

      assert.Not.is.True(trust.has_trust(file:absolute()))
    end)
  end)

  describe('should_trust', function()
    it('returns true if file already trusted', function()
      cache.set_cached({
        [file:absolute()] = utils.sha256(file:absolute())
      })

      assert.is.True(trust.should_trust(file:absolute()))
    end)

    it('calls confirm', function()
      local stubbed = stub(utils, 'confirm')

      trust.should_trust(file:absolute())

      assert.stub(utils.confirm).was.called(1)
      assert.stub(utils.confirm).was.called_with(
        "Do you want to trust " .. file:normalize() .. "?",
        {"yes", "no"},
        "no"
      )

      stubbed:revert()
    end)

    it('returns true if user answered "y"', function()
      local stubbed = stub(utils, 'confirm')
      stubbed.returns(1)

      assert.is.True(trust.should_trust(file:absolute()))

      stubbed:revert()
    end)

    it('returns false if user answered "f"', function()
      local stubbed = stub(utils, 'confirm')
      stubbed.returns(2)

      assert.Not.is.True(trust.should_trust(file:absolute()))

      stubbed:revert()
    end)
  end)

  describe('set_trust', function()
    it('sets the trust for file', function()
      assert.Not.is.True(trust.should_trust(file:absolute()))

      trust.set_trust(file:absolute(), true)

      assert.is.True(trust.should_trust(file:absolute()))

      trust.set_trust(file:absolute(), false)

      assert.Not.is.True(trust.should_trust(file:absolute()))
    end)
  end)
end)
