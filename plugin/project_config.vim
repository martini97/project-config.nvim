if exists('g:project_config') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:project_config_file")
  let g:project_config_file = ".vim/local.vim"
endif

if !exists("g:project_config_cache_file")
  let g:project_config_cache_file = simplify(stdpath("cache") . "/project_config/cache.json")
endif

augroup project_config
  autocmd!
  autocmd BufRead,BufNewFile,DirChanged * lua require('project_config').source_settings()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
let g:project_config = 1
