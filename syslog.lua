
local io = io
local print = print
local pairs = pairs
local ipairs = ipairs
local timer = timer
local socket = require('socket') -- luarocks install luasocket
local inotify = require('inotify') -- luarocks install inotify

module("syslog")

local ping
local watchers = {}

local function init_ping()
    ping = timer({ timeout = 0.1 })
    ping:start()
end

function read_log(watcher)
    local f, errno = io.open(watcher.filename)
    if not f then
        print("[syslog]: can't read " .. watcher.filename .. ":", errno)
        return
    end
    local diff = nil
    if watcher.fdlen then
        f:seek('set', watcher.fdlen)
        diff = f:read('*a'):gsub("\n$", "") -- remove trailing newline
    end
    watcher.fdlen = f:seek('end')
    f:close()
    return diff
end

function new_watcher(filename, callback)
    local ret = { filename = filename }
    local handle = inotify.init()
    local sd = { getfd = function () return handle:fileno() end }
    local wd = handle:addwatch(filename, inotify.IN_MODIFY)
    ret._handle = handle
    ret.watch = function ()
        if #socket.select({sd}, nil, 0) > 0 then
            local events = handle:read()
            if events then
                local diff = read_log(ret)
                if diff then
                    for _, ev in ipairs(events) do
                        callback(ret, ev, diff)
                    end
                end
            end
        end
    end
    ret.close = function ()
        handle:rmwatch(wd)
        handle:close()
        watchers[filename] = nil
    end
    read_log(ret) -- init fd
    ping:connect_signal("timeout", ret.watch)
    return ret
end


function watch(filename, callback)
    if not ping then init_ping() end
    watchers[filename] = watchers[filename] or new_watcher(filename, callback)
    return watchers[filename]
end
