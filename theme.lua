---------------------------
-- Default awesome theme --
---------------------------

local awful = require("awful")

theme = {}

theme.font          = "uni 05_53 6"
theme.icon_theme    = "default.kde4"

theme.bg_normal     = "#00000000"
theme.bg_systray    = "#00000000"
theme.bg_focus      = "#282828D8"--"#222222" * 85%
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#11111100"

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#424242"

theme.border_width  = 0
theme.border_normal = "#C50B0B"--"#000000"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"


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
theme.dock    = dir .. "dock.png"
theme.memory  = dir .. "memory.png"
theme.battery = dir .. "battery.png"
theme.nobattery = dir .. "nobattery.png"
theme.nomonitor = dir .. "nomonitor.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu = "> "
theme.menu_height = 14
theme.menu_width  = 100
theme.icon_theme = "default.kde4"

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

-- You can use your own command to set your wallpaper
theme.wallpapers = {
    { dir .. "icons/awesome16.png", center = true},
    {"/home/dodo/Pictures/7003_68fd_black.png", center = true},
    {"/home/dodo/Pictures/minimalcluster1900x1080.png", center = true},
    {"/home/dodo/Pictures/minimalblueprint1900x1080.png", center = true},
    {"/home/dodo/Pictures/blue_print_desktop_1600x1200_tranformed.jpg", maximize=true},
    {"/home/dodo/Pictures/meh.ro9016.png", center = true},
    "/home/dodo/Pictures/into_the_woods_1280x800.jpg",
    "/home/dodo/Pictures/planetoid_3_1280x800.png",
    "/home/dodo/Pictures/meh.ro7944.png",
    "/home/dodo/Pictures/meh.ro2263.png",
    "/home/dodo/Pictures/meh.ro3274.jpg",
}
-- default
theme.wallpaper = theme.wallpapers[1][1]
--

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
theme.screens_leftof  = dir .. "screens/left-of.png"
theme.screens_rightof = dir .. "screens/right-of.png"
theme.screens_above   = dir .. "screens/above.png"
theme.screens_below   = dir .. "screens/below.png"
theme.screens_sameas  = dir .. "screens/same-as.png"
theme.screens_off     = dir .. "screens/off.png"


return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
