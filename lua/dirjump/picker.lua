local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function fe(p)
	return vim.fn.fnameescape(p)
end

local function open_dir_buffer(dir, mode)
	if mode == "none" then
		return
	end
	if mode == "oil" or mode == "auto" then
		local ok, oil = pcall(require, "oil")
		if ok then
			oil.open(dir)
			return
		end
	end
	if mode == "neo-tree" or mode == "auto" then
		if vim.fn.exists(":Neotree") == 2 then
			pcall(vim.cmd, "Neotree reveal left dir=" .. fe(dir))
			return
		end
	end
	if mode == "nvim-tree" or mode == "auto" then
		local ok, api = pcall(require, "nvim-tree.api")
		if ok then
			api.tree.open({ path = dir, focus = true })
			return
		end
	end
	if mode == "mini.files" or mode == "auto" then
		local ok, mf = pcall(require, "mini.files")
		if ok then
			mf.open(dir, false)
			return
		end
	end
	-- "netrw" or fallback
	pcall(vim.cmd, "edit " .. fe(dir))
end

local M = {}

local function build_cmd(root, depth)
	if vim.fn.executable("fd") == 1 then
		return { "fd", "-t", "d", "-H", "-I", "-d", tostring(depth), ".", root }
	else
		return { "find", root, "-maxdepth", tostring(depth), "-type", "d" }
	end
end

function M.open(opts)
	local root = opts.search_root
	local depth = opts.depth
	local prompt = opts.prompt
	local scope = opts.scope or "cd"

	local home = vim.loop.os_homedir()
	local cmd = build_cmd(root, depth)

	pickers
		.new(opts, {
			prompt_title = prompt,
			finder = finders.new_oneshot_job(cmd, {
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry:gsub("^" .. home, "~"),
						ordinal = entry,
						path = entry,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				local function choose()
					local sel = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if sel and sel.value then
						vim.cmd(scope .. " " .. vim.fn.fnameescape(sel.value))
						vim.notify("cwd → " .. vim.fn.fnamemodify(sel.value, ":~"))
				  open_dir_buffer(sel.path, opts.open_dir or "auto")
			  end
		  end
		  map("i", "<CR>", choose)
		  map("n", "<CR>", choose)
		  return true
	  end,
  }):find()
end

return M
