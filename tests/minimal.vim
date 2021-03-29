set rtp +=.
set rtp +=~/.vim/autoload/plenary.nvim/
runtime! plugin/plenary.vim

let g:pid = trim(system('echo $$'))
let g:project_config_file = 'tmp/project_config_file.vim' . g:pid
let g:project_config_cache_file = '/tmp/project_config_cache_file' . g:pid

lua require("plenary/busted")
lua require("project_config")
