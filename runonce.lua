-- @author Peter J. Kranz (Absurd-Mind, peter@myref.net)
-- Any questions, criticism or praise just drop me an email

local awful = { util = require('awful.util') }
local hostname = require('utilz').hostname

local M = {}

-- get the current Pid of awesome
local function getCurrentPid()
    -- get awesome pid from pgrep
    local fpid = io.popen("pgrep -u " .. os.getenv("USER") .. " -o awesome")
    local pid = tonumber(fpid:read("*n"))
    fpid:close()

    -- sanity check
    if pid == nil or pid <= 0 then
        return -1
    end

    return pid
end

local function getOldPid(filename)
    -- open file
    local pidFile = io.open(filename)
    if pidFile == nil then
        return -1
    end

    -- read number
    local pid = tonumber(pidFile:read("*n"))
    pidFile:close()

    -- sanity check
    if not pid or pid <= 0 then
        return -1
    end

    return pid;
end

local function writePid(filename, pid)
    local pidFile = io.open(filename, "w+")
    if pidFile == nil then
        print("failed to write pid " .. pid .. " to " .. filename)
    else
        pidFile:write(pid)
        pidFile:close()
    end
end

local function shallExecute(oldPid, newPid)
    -- simple check if equivalent
    if oldPid == newPid then
        return false
    end

    return true
end


local function getPidFile()
    -- local host = awful.util.pread()
    host = hostname()
    return awful.util.getdir("cache") .. "/awesome." .. host .. ".pid"
end

-- run Once per real awesome start (config reload works)
-- does not cover "pkill awesome && awesome"
function M.run(shellCommand)
    -- check and Execute
    if shallExecute(M.oldPid, M.currentPid) then
        awful.util.spawn_with_shell(shellCommand)
    end
end

M.pidFile = getPidFile()
M.oldPid = getOldPid(M.pidFile)
M.currentPid = getCurrentPid()
writePid(M.pidFile, M.currentPid)

return M
