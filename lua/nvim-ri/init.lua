local ts_utils = require("nvim-treesitter.ts_utils")
local ts = vim.treesitter
local fn = vim.fn
local api = vim.api

local M = {}

local function get_word_under_cursor_with_ts()

  local node = ts_utils.get_node_at_cursor()

  if not node then
    return
  end

  local text = ts.get_node_text(node, 0)
  local first_word = text:match("%S+")

  return first_word

end

local function get_word_under_cursor_with_regex()
  return fn.expand("<cword>")
end

local function get_word_under_cursor()

  local word = get_word_under_cursor_with_ts()

  if not word then
    word = get_word_under_cursor_with_regex()
  end

  return word

end

function M.show_ri_output()

  local word = get_word_under_cursor()

  local output = fn.system("ri " .. word):gsub("\b.", "")

  if vim.v.shell_error ~= 0 then
    print("Error running `ri`: " .. output)
    return
  end

  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))

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

  api.nvim_open_win(buf, true, opts)
  api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
end

return M
