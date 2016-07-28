require('awful.util')
local _, posix = pcall(require, "posix")
local hostname = require("utilz").hostname()
-- return require("conf.classic")


local configs = {
  'default_' ..  hostname,
  'default',
  'classic',
}


local function try(lst)
  local cdir = awful.util.getdir ('config')
  for _, suffix in ipairs(lst) do
    if awful.util.file_readable(cdir .. '/conf/' .. suffix .. '.lua') then
      local status, module = pcall(require, 'conf.' .. suffix)
      if status then
        print("use config file: conf." .. suffix)
        return module
      else
        require('naughty')
        naughty.notify({ title = "Error loading conf/" .. suffix .. ".lua", text = module, timeout = 0 })
        print("error loading conf/" .. suffix .. '.lua:\n' .. module)
      end
    end
  end
end


if posix then
    local login = posix.getlogin()
    table.insert(configs, 1, login)
    table.insert(configs, 1, login .. '_' ..  hostname)
end


return try(configs) or {}

