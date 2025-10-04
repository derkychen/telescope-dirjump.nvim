local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("dirjump: telescope not found. Install nvim-telescope/telescope.nvim")
end

local dirjump = require("dirjump")              -- your plugin API
local picker  = require("dirjump.picker")

return telescope.register_extension({
  -- :Telescope dirjump <exported-fn>
  setup = function(ext_config)
    -- Allow users to set dirjump options through Telescope setup
    dirjump.setup(ext_config or {})
  end,
  exports = {
    -- `:Telescope dirjump dirs` will open the picker
    dirjump = function(opts)
      opts = vim.tbl_deep_extend("force", dirjump.opts or {}, opts or {})
      picker.open(opts)
    end,
  },
})

