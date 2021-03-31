std = "luajit"
cache = true
include_files = {"lua/project_config", "tests/*.lua", "*.luacheckrc"}
exclude_files = {"lua/project_config/sha2.lua"}
globals = {"vim"}
