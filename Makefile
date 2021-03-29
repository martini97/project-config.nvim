test:
	rm -rf ${PWD}/tmp
	nvim --headless \
		--noplugin \
		-u tests/minimal.vim \
		-c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"
