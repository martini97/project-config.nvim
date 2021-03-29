test:
	nvim --headless \
		--noplugin \
		-u tests/minimal.vim \
		-c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"


plenary.nvim:
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ~/.vim/autoload/plenary.nvim/

ci: plenary.nvim test
