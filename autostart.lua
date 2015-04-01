local run = require("runonce").run
local spawn = require("awful.util").spawn

if rc.conf.dbus and rc.conf.phone then
    spawn "kdeinit4" -- start kded dbus service
    if  luadbus and dbus.call_method then
        luadbus.call("loadModule", { args = {"s", "kdeconnect"},
            bus = 'session',
            path = '/kded',
            interface = 'org.kde.kded',
            destination = 'org.kde.kded',
        })
    else
        spawn "dbus-send --session --print-reply --dest='org.kde.kded' /kded org.kde.kded.loadModule string:kdeconnect"
    end
end

-- run "unagi" -- http://unagi.mini-dweeb.org/
-- run "nm-applet"
-- run "kmix"
run "akonaditray"


