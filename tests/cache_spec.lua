local Path = require('plenary.path')

local cache = require('project_config.cache')

describe('cache', function ()
  local cache_file = Path:new(vim.g.project_config_cache_file)

  after_each(function ()
    cache_file:rm()
  end)

  describe('get_cached', function ()
    it('returns empty dict if file does not exists', function()
      assert.is.Not.True(cache_file:exists())

      assert.are.same(cache.get_cached(), vim.empty_dict())
    end)

    it('writes empty json to file if does not exist', function()
      assert.is.Not.True(cache_file:exists())

      cache.get_cached()

      local file_contet = table.concat(cache_file:readlines(), "\n")
      assert.is.True(cache_file:exists())
      assert.are.same(file_contet, '{}')
    end)

    it('returns parsed json from cache', function()
      local value = {
        ["~/foo/bar/.vim/local.vim"] = "12345",
        ["~/lorem/ipsum/.vim/local.vim"] = "12345",
      }
      cache_file:write(vim.fn.json_encode(value), "w")

      
      assert.are.same(cache.get_cached(), value)
    end)
  end)

  describe('set_cached', function ()
    it('creates file if does not exists', function()
      assert.is.Not.True(cache_file:exists())

      cache.set_cached({})

      assert.is.True(cache_file:exists())
    end)

    it('writes stringfied json to file', function()
      local value = {
        ["~/foo/bar/.vim/local.vim"] = "12345",
        ["~/lorem/ipsum/.vim/local.vim"] = "12345",
      }

      cache.set_cached(value)

      assert.are.same(cache.get_cached(), value)
    end)
  end)
end)
