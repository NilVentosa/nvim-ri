local ts_utils = require("nvim-treesitter.ts_utils")
local ts = vim.treesitter

local function get_word_under_cursor()

  local node = ts_utils.get_node_at_cursor()

  if not node then
    print("No Treesitter node found under cursor")
    return
  end

  local text = ts.get_node_text(node, 0)
  local first_word = text:match("%S+")

  return first_word

end

local function show_ri_output()

  local word = get_word_under_cursor()

  local output = vim.fn.system("ri " .. word):gsub("\b.", "")

  if vim.v.shell_error ~= 0 then
    print("Error running `ri`: " .. output)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))

  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(20, vim.o.lines - 4)
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = (vim.o.lines - height) / 2,
    col = (vim.o.columns - width) / 2,
    style = "minimal",
    border = "rounded",
  }

  vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
end

vim.keymap.set("n", "<leader>kk", show_ri_output, { desc = "Run `ri` on word under cursor" })
