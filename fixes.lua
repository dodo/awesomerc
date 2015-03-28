local awful = require 'awful'


if jit then jit.on() end


awful.client.movetoscreen = function (c, s)
    local _screen = require("awful.screen")
    local sel = c or client.focus
    if sel then
        local sc = screen.count()
        if not s then
            s = sel.screen + 1
        end
        if s > sc then s = 1 elseif s < 1 then s = sc end
        sel.screen = s
        _screen.focus(s)
        if sel.screen ~= s then sel.screen = s end
    end
end

