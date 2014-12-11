local run = require("runonce").run
local spawn = require("awful.util").spawn

spawn "dbus-send --session --print-reply --dest='org.kde.kded' /kded org.kde.kded.loadModule string:kdeconnect"

-- run "unagi" -- http://unagi.mini-dweeb.org/
-- run "nm-applet"
-- run "kmix"


