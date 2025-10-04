local M = {}

local defaults = {
	search_root = vim.loop.os_homedir(),
	depth = 4,
	scope = "tcd", -- "cd" | "tcd" | "lcd"
	prompt = "cd to…",
}

M.opts = vim.deepcopy(defaults)

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

function M.pick(opts)
	opts = vim.tbl_deep_extend("force", M.opts, opts or {})
	require("dirjump.picker").open(opts)
end

return M
