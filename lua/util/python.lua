-- ~/.config/nvim/lua/util/python.lua
local M = {}

-- Get Python path with virtualenv support
function M.get_python_path()
  local cwd = vim.fn.getcwd()

  local virtual_env = vim.env.VIRTUAL_ENV
  if virtual_env and virtual_env ~= "" then
    local virtual_env_python = virtual_env .. "/bin/python"
    if vim.fn.executable(virtual_env_python) == 1 then
      return virtual_env_python
    end
  end

  local candidates = {
    cwd .. "/.venv/bin/python",
    cwd .. "/venv/bin/python",
  }

  for _, python in ipairs(candidates) do
    if vim.fn.executable(python) == 1 then
      return python
    end
  end

  local system_python = vim.fn.exepath("python3")
  if system_python ~= "" then
    return system_python
  end

  return "/usr/bin/python3"
end

return M
