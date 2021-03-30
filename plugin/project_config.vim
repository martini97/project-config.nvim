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
  autocmd BufRead,BufNewFile,DirChanged * lua require('project_config').source_config()
augroup END

command! -nargs=0 ProjectConfigEdit lua require('project_config').edit_config()
command! -nargs=0 ProjectConfigUntrust lua require('project_config').untrust_config()
nnoremap <silent> <plug>ProjectConfigEdit :lua require('project_config').edit_config()<cr>
nnoremap <silent> <plug>ProjectConfigUntrust :lua require('project_config').untrust_config()<cr>

let &cpo = s:save_cpo
unlet s:save_cpo
let g:project_config = 1
