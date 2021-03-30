local Path = require("plenary.path")
local stub = require('luassert.stub')
local match = require('luassert.match')

local utils = require('project_config.utils')

local know_sha_keymap = {
  ['lorem ipsum'] = '5e2bf57d3f40c4b6df69daf1936cb766f832374b4fc0259a7cbff06e2f70f269',
  ['Sed ut perspiciatis unde omnis iste natus error sit voluptatem'] =
    'a385db1cb85e9969d0af177f66b7d5eba60788d24b083cf3fc254cb5743737ea',
  ['with\nline\nbreak'] = 'ad5b39b6a4be0f580a28a6c20d3a82a6f5f3890b6eae051f7d243d257a130a2f',
}

describe('utils', function ()
  describe('sha256', function ()
    it('return string sha', function ()
      for str, sha in pairs(know_sha_keymap) do
        assert.are.same(utils.sha256(str), sha)
      end
    end)
  end)

  describe('file_signature', function ()
    it('return string sha', function ()
      for str, _ in pairs(know_sha_keymap) do
        local file = Path:new('/tmp/file-signature.txt')
        file:write(str, 'w')
        assert.are.same(
          utils.file_signature(file),
          utils.sha256(string.format('%q', str))
        )
        file:rm()
      end
    end)

    it('signature changes when file changes', function ()
      local file = Path:new('/tmp/file-signature-changed.txt')

      file:write('lorem ipsum', 'w')
      local old_signature = utils.file_signature(file)

      file:write('dolor sit', 'w')
      local new_signature = utils.file_signature(file)

      assert.Not.are.same(old_signature, new_signature)
      file:rm()
    end)

    it('return nil if file does not exist', function ()
      local file = Path:new('tmp/missing.txt')
      assert.are.same(utils.file_signature(file), nil)
    end)
  end)

  describe('get_config_file', function ()
    it('return cwd config file', function ()
      local stubbed = stub(vim.loop, 'cwd')
      stubbed.returns('/home/user/linux/.config/nvim')

      local received = utils.get_config_file():absolute()
      local expected = vim.fn.stdpath('data') ..
        '/project_config/aa9f5819ba69643a70dd2da3f5f32882d1ff4354196446048e8e8f7016f3d6bd.vim'

      assert.are.same(expected, received)
      stubbed:revert()
    end)
  end)

  describe('index_of', function ()
    it('index_of', function ()
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
end)
