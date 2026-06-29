local M = {}

---Check if we're on Windows
---@return boolean
local function is_windows()
	return vim.loop.os_uname().version:match("Windows")
end

---Return the full path to an executable inside the Poetry-managed .venv if available.
---@param exe string
---@return string
function M.get_bin(exe)
	local handle = io.popen("poetry env info -p 2>/dev/null")
	if not handle then
		return exe
	end

	local result = handle:read("*a")
	handle:close()
	local venv = vim.fn.trim(result)
	local bin_dir = is_windows() and "Scripts" or "bin"
	local path = venv .. "/" .. bin_dir .. "/" .. exe

	if vim.fn.executable(path) == 1 then
		return path
	else
		return exe
	end
end

---Return the Python interpreter path for Pyright (preferring .venv)
---@param root_dir string
---@return string
function M.get_python_path(root_dir)
	local bin_dir = is_windows() and "Scripts" or "bin"
	local poetry_python = root_dir .. "/.venv/" .. bin_dir .. "/python"

	if vim.fn.executable(poetry_python) == 1 then
		return poetry_python
	end

	local handle = io.popen("poetry env info -p 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		local venv = vim.fn.trim(result)
		local poetry_bin = venv .. "/" .. bin_dir .. "/python"
		if vim.fn.executable(poetry_bin) == 1 then
			return poetry_bin
		end
	end

	-- Fallbacks
	if vim.fn.executable("python3") == 1 then
		return vim.fn.exepath("python3")
	elseif vim.fn.executable("python") == 1 then
		return vim.fn.exepath("python")
	else
		return "python"
	end
end

return M
