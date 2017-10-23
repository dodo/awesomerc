---------------------------
-- Default awesome theme --
---------------------------

local rc = { conf = require("conf") }

local awful = require("awful")
local couth = require("couth")
local naughty = require("naughty")

theme = {}

theme.font          = "uni 05_53 5"
theme.widget_font   = "ProggyTinyTT" -- no font size here

theme.bg_normal     = "#00000022"
theme.bg_systray    = "#00000022"
theme.bg_focus      = "#282828D8"--"#222222" * 85%
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#11111122"

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#424242"

theme.border_width  = 0
theme.border_normal = "#C50B0B"--"#000000"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"


-- default values for notifications
naughty.config.defaults.font = "uni 05_53 6"
naughty.config.defaults.border_width = "0"
naughty.config.defaults.bg = "#00000066"
naughty.config.defaults.opacity = 0.77


local dir = awful.util.getdir("config") .. "/theme/"
-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = dir .. "squaref.png"
theme.taglist_squares_unsel = dir .. "square.png"

theme.tasklist_floating_icon = dir .. "floating.png"

-- icons
theme.none    = dir .. "none.png"
theme.dock    = dir .. "dock.png"
theme.memory  = dir .. "memory.png"
theme.battery = dir .. "battery.png"
theme.nobattery = dir .. "nobattery.png"
theme.nomonitor = dir .. "nomonitor.png"
theme.wicd = {}
theme.wicd.wired      = dir .. "wicd/wired.png"
theme.wicd.unknown    = dir .. "wicd/unknown.png"
theme.wicd.wireless   = dir .. "wicd/wireless.png"
theme.wicd.suspended  = dir .. "wicd/suspended.png"
theme.wicd.connecting = dir .. "wicd/connecting.png"
theme.wicd.not_connected = dir .. "wicd/not_connected.png"
theme.phone = {}
theme.phone.battery = dir .. "phone/battery.png"
theme.mpris = { none = theme.none }
theme.mpris.next     = dir .. "mpris/next.png"
theme.mpris.paused   = dir .. "mpris/paused.png"
theme.mpris.playing  = dir .. "mpris/playing.png"
theme.mpris.stopped  = dir .. "mpris/stopped.png"
theme.mpris.previous = dir .. "mpris/previous.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu = "> "
theme.menu_height = 14
theme.menu_width  = 100
theme.icon_theme = "breeze-dark"--,"default.kde4","hicolor"
theme.mpris.height = theme.menu_height


-- Variables set for prompt design:
theme.prompt = {
    cmd = "» ",
    lua = "› ",
}

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = dir .. "titlebar/close_normal.png"
theme.titlebar_close_button_focus  = dir .. "titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = dir .. "titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = dir .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = dir .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = dir .. "titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = dir .. "titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = dir .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = dir .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = dir .. "titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = dir .. "titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = dir .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = dir .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = dir .. "titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = dir .. "titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = dir .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = dir .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = dir .. "titlebar/maximized_focus_active.png"

-- default wallpapers
theme.default_wallpapers = {{ dir .. "icons/awesome64.png", center = true }}

-- You can use your own layout icons like this:
theme.layout_rows = dir .. "layouts/rows.png"
theme.layout_fairh = dir .. "layouts/fairh.png"
theme.layout_fairv = dir .. "layouts/fairv.png"
theme.layout_columns = dir .. "layouts/columns.png"
theme.layout_floating  = dir .. "layouts/floating.png"
theme.layout_magnifier = dir .. "layouts/magnifier.png"
theme.layout_max = dir .. "layouts/max.png"
theme.layout_fullscreen = dir .. "layouts/fullscreen.png"
theme.layout_tilebottom = dir .. "layouts/tilebottom.png"
theme.layout_tileleft   = dir .. "layouts/tileleft.png"
theme.layout_tile = dir .. "layouts/tile.png"
theme.layout_tiletop = dir .. "layouts/tiletop.png"
theme.layout_spiral  = dir .. "layouts/spiral.png"
theme.layout_dwindle = dir .. "layouts/dwindle.png"

theme.awesome_icon = dir .. "icons/awesome16.png"

-- You can use your own screen settings icons like this:
theme.randr = {}
theme.randr.leftof  = dir .. "screens/left-of.png"
theme.randr.rightof = dir .. "screens/right-of.png"
theme.randr.above   = dir .. "screens/above.png"
theme.randr.below   = dir .. "screens/below.png"
theme.randr.sameas  = dir .. "screens/same-as.png"
theme.randr.off     = dir .. "screens/off.png"

couth.CONFIG.NOTIFIER_FONT = "mono 5"
couth.CONFIG.INDICATOR_BARS = {'▏','▎','▍','▌','▋','▊','▉','█'}
couth.CONFIG.INDICATOR_BORDERS = {'',''}

if rc.conf.theme ~= nil then
  for k,v in pairs(rc.conf.theme) do
    theme[k] = v
  end
end

-- set the default wallpapers if the user has not set any
if rc.conf.wallpapers == nil then
  rc.conf.wallpapers = theme.default_wallpapers
end

-- we need a early on wallpaper
theme.wallpaper = theme.default_wallpaper

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
