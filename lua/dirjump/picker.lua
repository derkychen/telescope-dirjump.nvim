local pickers      = require("telescope.pickers")
local finders      = require("telescope.finders")
local conf         = require("telescope.config").values
local actions      = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local function build_cmd(root, depth)
  if vim.fn.executable("fd") == 1 then
    return { "fd", "-t", "d", "-H", "-I", "-d", tostring(depth), ".", root }
  else
    return { "find", root, "-maxdepth", tostring(depth), "-type", "d" }
  end
end

function M.open(opts)
  local root   = opts.search_root
  local depth  = opts.depth
  local prompt = opts.prompt
  local scope  = opts.scope or "cd"

  local home = vim.loop.os_homedir()
  local cmd  = build_cmd(root, depth)

  pickers.new(opts, {
    prompt_title = prompt,
    finder = finders.new_oneshot_job(cmd, {
      entry_maker = function(entry)
        return {
          value   = entry,
          display = entry:gsub("^" .. home, "~"),
          ordinal = entry,
          path    = entry,
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
        end
      end
      map("i", "<CR>", choose)
      map("n", "<CR>", choose)
      return true
    end,
  }):find()
end

return M

