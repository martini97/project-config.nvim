# project_settings.nvim

Define variable per project.

## **⚠️ WARNING ⚠️**

This plugin allows for the execution of vimscript, this could result
in the execution of malicious code. To remediate that we only source files
the user marks as trusted using the SHA256 of the file to track if it has been
changed.

## Installing

This plugins requires [*plenary.nvim*](https://github.com/nvim-lua/plenary.nvim),
you can install everything with [*packer.nvim*](https://github.com/wbthomason/packer.nvim):

```lua
  use {
    "martini97/project-config.nvim",
    requires = {"nvim-lua/plenary.nvim"},
  }
```

## Functions

### `require('project_config').source_settings()`

This is the main function which is executed via autocmd, you can also map it to
a command if you'd like. It will check if the file is trusted, if not it will ask
if the user wants to trust in the file, if they do then it will source the file.

### `require('project_config').untrust()`

If you no longer wants to trust a file you can use this function to remove it from
the trusted files, you can also map this to a command if you'd like.

## Variables

### `g:project_config_file`

Path to the settings file, defaults to `.vim/local.vim`.

### `g:project_config_cache_file`

Path to the file where we will store the trust database, defaults to
`~/.cache/nvim/project_config/cache.json`

## TODO

+ [x] Implement trusted files
+ [x] Write tests
+ [ ] Preview file before execution
+ [ ] Allow user to distrust a file permanently
