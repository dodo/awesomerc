require('awful.util')
local posix = require("posix")
local hostname = require("utilz").hostname()
-- return require("conf.classic")
local login = posix.getlogin()

local function try_configs(lst)
  for _, suffix in ipairs(lst) do
    local status, module = pcall(require, 'conf.' .. suffix)
    local conf = status and module or nil
    if conf then
      print("use config file: conf." .. suffix)
      return conf
    end
  end
end

conf = try_configs {
  login .. '_' ..  hostname,
  login,
  'default_' ..  hostname,
  'default',
  'classic'
}

if conf then
  return conf
else
  return {}
end
