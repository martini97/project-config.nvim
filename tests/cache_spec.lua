local Path = require("plenary.path")

local cache = require('project_config.cache')

describe('cache', function ()
  local cache_file = Path:new(vim.g.project_config_cache_file)

  after_each(function ()
    cache_file:rm()
  end)

  describe('get_cached', function ()
    it('returns empty dict if file does not exists', function ()
	    cache_file:rm()

      assert.are.same(cache.get_cached(), vim.empty_dict())
    end)

    it('creates file if it doesnt exist', function ()
	    cache_file:rm()
      cache.get_cached()

	    assert.is.True(cache_file:exists())
	    assert.are.same(table.concat(cache_file:readlines(), '\n'), '{}')
    end)

    it('returns parsed data', function ()
      local data = {
        ['~/some/project'] = 123456,
        ['~/other/project'] = '98765',
      }

	    cache_file:write(vim.fn.json_encode(data), 'w')

	    assert.are.same(cache.get_cached(), data)
    end)
  end)

  describe('set_cached', function ()
    it('set data if file missing', function ()
      cache_file:rm()

      cache.set_cached('my-key', 'value')

	    assert.are.same(
        table.concat(cache_file:readlines(), '\n'),
        '{"my-key": "value"}'
      )
    end)

    it('does not erase other keys', function ()
      cache_file:write([[{"other-key": "other value"}]], 'w')

      cache.set_cached('my-key', 'value')

	    assert.are.same(
        table.concat(cache_file:readlines(), '\n'),
        '{"other-key": "other value", "my-key": "value"}'
      )
    end)

    it('overwrites key', function ()
      cache_file:write([[{"my-key": "old value"}]], 'w')

      cache.set_cached('my-key', 'new value')

	    assert.are.same(
        table.concat(cache_file:readlines(), '\n'),
        '{"my-key": "new value"}'
      )
    end)
  end)
end)
