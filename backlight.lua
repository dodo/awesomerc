---------------------------------------------------------------------------
--
--    couth backlight indicator library.
--
--    In order for this to work, mpc must be on your path, and mpd must be
--    running on the host (obviously)
--
--    Usage Examples:
--
--      -- Get the the volume from localhost and return an bar indicator
--      -- for display
--      couth.back:getLight()
--
--      -- Set the the backlight from localhost to NEW_VALUE, and
--      -- return a bar indicator that displays the new value.
--      -- NOTE: NEW_VALUE can be any string that "xbacklight" will
--      -- accept as an argument, e.g.,
--      --    "=50" to set light to 50%,
--      --    "+5" to increase light by 5%,
--      --    "-5" to decrease light by 5%,
--      couth.mpc:setLight(NEW_VALUE)
--
--
--    I use this configuration in ~/.config/awesome/rc.lua to adjust my backlight:
--
--    awful.key({ modkey }, "XF86MonBrightnessDown",    function () couth.notifier:notify( couth.back:setLight('-5')) end),
--    awful.key({ modkey }, "XF86MonBrightnessUp",    function () couth.notifier:notify( couth.back:setLight('+5')) end),
--    awful.key({ modkey, "Shift" }, "XF86MonBrightnessDown",    function () couth.notifier:notify( couth.back:setLight('-10')) end),
--    awful.key({ modkey, "Shift" }, "XF86MonBrightnessUp",    function () couth.notifier:notify( couth.back:setLight('+10')) end) end)
--
---------------------------------------------------------------------------
local pread = require("uzful.util").pread
local couth = require("couth")
couth.back = {}

function couth.back:getLight()
    local val = pread("xbacklight -get")
    return '<span color="green">☀ ' .. couth.indicator.barIndicator(val) .. "</span>"
end

function couth.back:setLight(val)
    io.popen("xbacklight -time 0 " .. (val < 0 and "-" or "+") .. math.abs(val)):close()
    return self:getLight()
end
