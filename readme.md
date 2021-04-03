# project_settings.nvim

![ci](https://github.com/martini97/project-config.nvim/actions/workflows/ci.yml/badge.svg?branch=main)

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

### `require('project_config').source_config()`

Checks if a config file exists for the current cwd and if signature matches the
cached on, and asks for permission to source if it changed, if it's the same then
it will source the config.

### `require('project_config').edit_config()`

Create or edit the config file for the current cwd.

### `require('project_config').untrust_config()`

Remove the config file from the current cwd from trusted files.

## Variables

### `g:project_config_cache_file`

Path to the file where we will store the trust database, defaults to
`stdpatch('cache')/project_config/cache.json`

## Commands

### ProjectConfigEdit

Wrapper for `require('project_config').edit_config()`.

### ProjectConfigUntrust

Wrapper for `require('project_config').untrust_config()`.

## Mappings

This project defines some mappings that the user can plug to their config.

### <Plug>ProjectConfigEdit

Wrapper for `require('project_config').edit_config()`.

```vim
nmap <space>. <plug>ProjectConfigEdit
```

### ProjectConfigUntrust

Wrapper for `require('project_config').untrust_config()`.

```vim
nmap <space>! <plug>ProjectConfigUntrust
```

## TODO

+ [x] Implement trusted files
+ [x] Write tests
+ [x] Save config files on data dir
+ [x] Command to edit/create config file
+ [-] Preview file before execution
+ [ ] Allow user to distrust a file permanently
+ [ ] Write docs (`:h project_config`)
+ [ ] Use `:inputlist()` instead of confirm
