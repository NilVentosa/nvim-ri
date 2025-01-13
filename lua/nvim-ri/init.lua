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

local function get_word_under_cursor_expand()
	return fn.expand("<cword>")
end

local function get_word_under_cursor()
	local word = get_word_under_cursor_with_ts()

	if not word then
		word = get_word_under_cursor_expand()
	end

	return word
end

local function get_selected_text()
local start_pos = fn.getpos("'<")
  local end_pos = fn.getpos("'>")

  local line_number = start_pos[2]
  local start_col = start_pos[3]
  local end_col = end_pos[3] + 1

  local line = fn.getline(line_number)

  return string.sub(line, start_col, end_col - 1)
end

local function display_in_new_window(text)
	local buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))

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

local function show_ri_output(word)
	local output = fn.system("ri " .. word):gsub("\b.", "")

	if vim.v.shell_error ~= 0 then
		print("Error running `ri`: " .. output)
		return
	end

	display_in_new_window(output)
end

function M.ri_for_selected()
  local word = get_selected_text()
	show_ri_output(word)
end

function M.ri_under_cursor()
	local word = get_word_under_cursor()
	show_ri_output(word)
end

return M
