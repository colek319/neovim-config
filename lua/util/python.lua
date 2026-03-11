-- ~/.config/nvim/lua/util/python.lua
local M = {}

-- Get Python path with virtualenv support
function M.get_python_path()
  local venv = vim.fn.getcwd() .. '/venv/bin/python'
  if vim.fn.filereadable(venv) == 1 then
    return venv
  end
  return '/usr/bin/python3'
end

return M