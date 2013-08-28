 -- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local keydoc = require("keydoc")
local lognotify = require("lognotify")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

menubar.cache_entries = true
menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu
menubar.geometry.height = 14

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- Widget library
vicious = require("vicious")
-- Load Debian menu entries
require("debian.menu")
-- Load freedesktop menu
require('freedesktop.utils')
require('freedesktop.menu')
-- utils Library
utilz = require("utilz")
uzful = require("uzful")
require("uzful.restore")
-- keyboard mouse control
require("rodentbane")
-- audio control
require("couth")
require("couth.lib.alsa")
couth.CONFIG.NOTIFIER_FONT = "mono 5"
couth.CONFIG.INDICATOR_BARS = {'','▏','▎','▍','▌','▋','▊','▉','█'}
couth.CONFIG.ALSA_CONTROLS = {
    'Master',
    'PCM',
}
couth.indicator.barIndicator = function (prct)
    local BAR = couth.CONFIG.INDICATOR_BARS
    local maxBars = couth.CONFIG.INDICATOR_MAX_BARS
    local num_bars = maxBars * prct * 0.01
    local full_bars = math.floor(num_bars)
    local part_bar = math.floor((num_bars - full_bars) * 7) + 1
    local bar = string.rep(BAR[9], full_bars) .. BAR[part_bar]
    return bar .. string.rep( " ", maxBars - full_bars - (part_bar > 1 and 1 or 0))
end
require("backlight") -- uses couch too


-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/theme.lua")
uzful.notifications.patch()
uzful.util.patch.vicious()

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'default.kde4'

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    uzful.layout.suit.strips.rows,
    uzful.layout.suit.strips.columns,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

SCREEN = {LVDS1=1}

-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.centered(beautiful.wallpaper, s, theme.bg_normal)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
tags_numbered = false
tag_names = {"☼", "✪", "⌥", "✇", "⌤", "⍜", "⌬", "♾", "⌘", "⚗", "Ω", "·"}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tag_names, s, layouts[12])
end

myrestorelist = uzful.restore(layouts)
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu

detailed_graphs = uzful.menu.toggle_widgets()

taglist_filter = uzful.util.functionlist({
    awful.widget.taglist.filter.noempty,
    awful.widget.taglist.filter.all })

local menu_graph_text = function ()
    return (detailed_graphs.visible() and "disable" or "enable") .. " graphs"
end

local menu_tags_text = function ()
    return (tags_numbered and "symbol" or "number") .. " tags"
end

local menu_taglist_text = function ()
    if taglist_filter.current() == 1 then
        return "show all tags"
    elseif taglist_filter.current() == 2 then
        return "hide empty tags"
    else
        return "nil"
    end
end

myfreedesktopmenu = freedesktop.menu.new()

myscreensmenu = {
    { "same-as",
        "xrandr --output LVDS1 --auto --output VGA1 --auto --same-as  LVDS1",
        beautiful.screens_sameas },
    { "left-of",
        "xrandr --output LVDS1 --auto --output VGA1 --auto --left-of  LVDS1",
        beautiful.screens_leftof },
    { "right-of",
        "xrandr --output LVDS1 --auto --output VGA1 --auto --right-of LVDS1",
        beautiful.screens_rightof },
    { "above",
        "xrandr --output LVDS1 --auto --output VGA1 --auto --above    LVDS1",
        beautiful.screens_above },
    { "below",
        "xrandr --output LVDS1 --auto --output VGA1 --auto --below    LVDS1",
        beautiful.screens_below },
}
if screen.count() > 1 then
    table.insert(myscreensmenu, 1, { "off",
        "xrandr --output LVDS1 --auto --output VGA1 --off",
        beautiful.screens_off })
end

mysystemmenu = {}
lock          = function () awful.util.spawn_with_shell("xtrlock")           end
screenshot    = function () awful.util.spawn("ksnapshot")                    end
invert_screen = function () awful.util.spawn("xcalib -invert -alter", false) end
table.insert(mysystemmenu, { "invert screen", invert_screen })
table.insert(mysystemmenu, { "screenshot", screenshot })
table.insert(mysystemmenu, { "lock", lock })
if dbus then
    table.insert(mysystemmenu, { "suspend", function ()
        naughty.notify({ text = "system suspsending  ... " })
        awful.util.spawn_with_shell("sync && dbus-send --system --print-reply --dest='org.freedesktop.UPower' /org/freedesktop/UPower org.freedesktop.UPower.Suspend &")
        lock()
    end })
end

myawesomemenu = {
   { "system", mysystemmenu },
   { "second screen", myscreensmenu },
   { "wallpapers", uzful.menu.wallpaper.menu(theme.wallpapers)},
   { menu_taglist_text(), function (m)
        taglist_filter.next()
        m.label:set_text(menu_taglist_text())
        for s = 1, screen.count() do
            tags[s][1].name = tags[s][1].name
        end
   end },
   { menu_tags_text(), function (m)
        tags_numbered = not tags_numbered
        for s = 1, screen.count() do
            for i, t in ipairs(tags[s]) do
                t.name = tags_numbered and tostring(i) or tag_names[i]
            end
        end
        m.label:set_text(menu_tags_text())
     end },
   { menu_graph_text(), function (m)
        detailed_graphs.toggle()
        m.label:set_text(menu_graph_text())
     end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "keybindings", keydoc.display },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
}

mymainmenu = awful.menu({ max = 100,
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "Menu", myfreedesktopmenu, freedesktop.utils.lookup_icon({ icon = 'kde' }) },
    { "Debian", debian.menu.Debian_menu.Debian, freedesktop.utils.lookup_icon({ icon = 'debian-logo' }) },
    { "open terminal", terminal, freedesktop.utils.lookup_icon({ icon = 'terminal' }) },
                        })

for name, preset in pairs(naughty.config.presets) do
    preset.font = "uni 05_53 6"
    preset.border_width = "0"
    preset.bg = "#00000066"
    preset.opacity = 0.77
end


local syslog_enabled = true
if syslog_enabled then
    ilog = lognotify{ logs = {
            syslog = { file = "/var/log/syslog" },
--             xsessionerrors = { file = "/home/dodo/.xsession-errors" },
        },
        interval = 0.1,
    }
    local sllines = 64
    local text = ""

    mysyslogtext = wibox.widget.textbox()
    mysyslogtext:set_valign('bottom')
    mysyslogtext:set_text(" \n")

    ilog.notify = function (self, name, file, diff)
        text = string.format("%s\n%s", text, diff)
        text = utilz.lineswrap(text, sllines)
        mysyslogtext:set_text(text)
    end
    ilog:start()

    local s = SCREEN.LVDS1
    mysyslog = uzful.widget.infobox({ screen = s,
        width = screen[s].geometry.width,
        height = sllines * beautiful.get_font_height(theme.font),
        position = "bottom", align = "left",
        visible = true, ontop = false,
        widget = mysyslogtext })
end

-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
--                                      menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock(' %H:%M ')
mytextclock:set_font("sans 5")
mycal = uzful.widget.calendar({ font = 7,
    head = '<span color="#666666">$1</span>',
    week = '<span color="#999999">$1</span>',
    day  = '<span color="#BBBBBB">$1</span>',
    number  = '<span color="#EEEEEE">$1</span>',
    current = '<span color="green">$1</span>',
})

mytextclock:buttons(awful.util.table.join(
    awful.button({         }, 1, function()  mycal:switch_month(-1)  end),
    awful.button({         }, 2, function()  mycal:now()             end),
    awful.button({         }, 3, function()  mycal:switch_month( 1)  end),
    awful.button({         }, 4, function()  mycal:switch_month(-1)  end),
    awful.button({         }, 5, function()  mycal:switch_month( 1)  end),
    awful.button({ 'Shift' }, 1, function()  mycal:switch_year(-1)  end),
    awful.button({ 'Shift' }, 2, function()  mycal:now()             end),
    awful.button({ 'Shift' }, 3, function()  mycal:switch_year( 1)  end),
    awful.button({ 'Shift' }, 4, function()  mycal:switch_year(-1)  end),
    awful.button({ 'Shift' }, 5, function()  mycal:switch_year( 1)  end)
))

-- Memory Progressbar
mymem = uzful.widget.progressimage({
    x = 2, y = 2, width = 5, height = 10,
    image = theme.memory, draw_image_first = false })
uzful.widget.set_properties(mymem.progress, {
    vertical = true, background_color = "#000000",
    border_color = nil, color = "#0173FF" })
--mymem:set_color({ "#001D40", "#535d6c", "#0173FF" })
vicious.register(mymem.progress, vicious.widgets.mem, "$1", 13)

-- Battery Progressbar
local htimer = nil
local dock_online = ((uzful.util.scan.sysfs({
    property = {"modalias", "platform:dock"},
    sysattr = {"type", "dock_station"},
    subsystem = "platform",
}).sysattrs[1] or {}).docked == "1")
local power_supply_online = ((uzful.util.scan.sysfs({
    property = {"power_supply_name", "AC"},
    subsystem = "power_supply",
}).properties[1] or {}).power_supply_online == "1")
local battery_online = (uzful.util.scan.sysfs({
    property = {"power_supply_name", "BAT0"},
    subsystem = "power_supply"}).length > 0)

mybat = uzful.widget.progressimage({
    image = battery_online and (dock_online and theme.dock or theme.battery) or theme.nobattery,
    draw_image_first = not power_supply_online,
    x = 3, y = 4, width = 3, height = 7 })
uzful.widget.set_properties(mybat.progress, {
    ticks = true, ticks_gap = 1,  ticks_size = 1,
    vertical = true, background_color = "#000000",
    border_color = nil, color = "#FFFFFF" })
vicious.register(mybat.progress, vicious.widgets.bat, "$2", 45, "BAT0")

htimer = uzful.util.listen.sysfs({ subsystem = "power_supply", timer = htimer },
                                 function (device, props)
    if props.action == "change" and props.power_supply_name == "AC" then
        if props.power_supply_online == "0" then
            mybat.draw_image_first()
            power_supply_online = false
        else
            mybat.draw_progress_first()
            power_supply_online = true
        end
    elseif props.power_supply_name == "BAT0" then
        if props.action == "remove" then
            mybat.draw_progress_first()
            mybat.progress:set_value(nil)
            mybat:set_image(theme.nobattery)
            battery_online = false
        elseif props.action == "add" then
            if not power_supply_online then
                mybat.draw_image_first()
            end
            mybat:set_image(dock_online and theme.dock or theme.battery)
            vicious.force({mybat.progress, mybtxt})
            battery_online = true
        end
    end
end).timer

htimer = uzful.util.listen.sysfs({ subsystem = "platform", timer = htimer },
                                 function (device, props, attrs)
    if props.action == "change" and
       props.modalias == "platform:dock" and
       attrs.type == "dock_station"
    then
        if props.event == "undock" then
            dock_online = false
        elseif props.event == "dock" then
            dock_online = true
        end
        if battery_online then
            mybat:set_image(dock_online and theme.dock or theme.battery)
        end
    end
end).timer


htimer = uzful.util.listen.sysfs({ subsystem = "drm", timer = htimer },
                                 function (device, props)
    if props.action == "change" and props.devtype == "drm_minor" and screen.count() > 1 then
        naughty.notify({
            timeout = 0,
            hover_timeout = 0.1,
            position = "bottom_right",
            icon = theme.nomonitor })
    end
end).timer

local mynotibat, mycritbat_old_val = nil, 0
mycritbat = uzful.util.threshold(0.2,
    function (val)
        mycritbat_old_val = val
        mybat.progress:set_background_color("#000000")
        if mynotibat ~= nil then  naughty.destroy(mynotibat)  end
    end,
    function (val)
        if not battery_online then
            mybat.progress:set_background_color("#000000")
            if mynotibat ~= nil then  naughty.destroy(mynotibat)  end
            return
        end
        mybat.progress:set_background_color("#8C0000")
        if val < 0.1 and val <= mycritbat_old_val then
            if mynotibat ~= nil then  naughty.destroy(mynotibat)  end
            mynotibat = naughty.notify({
                preset = naughty.config.presets.critical,
                title = "Critical Battery Charge",
                text =  "only " .. (val*100) .. "% remaining."})
        end
        mycritbat_old_val = val
    end)
vicious.register(mycritbat, vicious.widgets.bat, "$2", 90, "BAT0")

-- Network Progressbar
mynet = nil
mynettxt = nil
if dbus then
    mynet = uzful.widget.progressimage({
        image = theme.wicd.unknown,
        draw_image_first = false,
        x = 1, y = 2, width = 3, height = 9 })
    uzful.widget.set_properties(mynet.progress, {
        ticks = true, ticks_gap = 1,  ticks_size = 1,
        vertical = true, background_color = "#000000",
        border_color = nil, color = "#33FF3399" })
    mynettxt = wibox.widget.textbox()
    mynettxt:set_font("ProggyTinyTT 7")
    mynettxt:set_text(" ")
    local connecting = false
    dbus.connect_signal("org.wicd.daemon", function (ev, status, data)
        local state = ({
            "not_connected","connecting","wireless","wired","suspended"
        })[status + 1] or "unknown"
--         print("changed wicd status to "..state)
        mynet:set_image(theme.wicd[state])
        if connecting and (state == "wireless" or state == "wired") then
            connecting = false
            mynetgraphs.update_widget()
        end
        if state == "wireless" then
            mynet.progress:set_value((data[3] or 0) / 100)
        else
            if state == "connecting" then
                connecting = true
                if data[1] == "wireless" then
                    mynetgraphs.switch("wlan0")
                elseif data[1] == "wired" then
                    mynetgraphs.switch("eth0")
                end
            end
            mynet.progress:set_value(nil)
        end
        local text = ""
        for _, line in ipairs(data) do text = text .. line .. "\n" end
        if text == "" or text == "\n" then text = " " end
        mynettxt:set_text(text)
--         print(require('serpent').block(data))
    end)
    dbus.add_match("system",
             "type='signal',interface='org.wicd.daemon',member='StatusChanged'")
end

-- Memory Text
mymtxt = wibox.widget.textbox()
mymtxt:set_font("ProggyTinyTT 12")
vicious.register(mymtxt, vicious.widgets.mem,
    '$4mb free, $1%', 60)

-- Battery Text
mybtxt = wibox.widget.textbox()
mybtxt:set_font("ProggyTinyTT 12")
vicious.register(mybtxt, vicious.widgets.bat,
    '$1$3 $2%', 60, "BAT0")

-- Temperature Info
mytemp = wibox.widget.textbox()
mytemp:set_font("sans 6")
mycrittemp = uzful.util.threshold(0.8,
    function (val)
        mytemp:set_markup('<span color="red">' ..
            (val*100) .. '°</span>')
    end,
    function (val)
        mytemp:set_markup('<span color="#666666" size="small">' ..
            (val*100) .. '°</span>')
    end)
vicious.register(mycrittemp, vicious.widgets.thermal, "$1", 30, "thermal_zone0")


mytempgraph = awful.widget.graph({ width = 161, height = 42 })
table.insert(detailed_graphs.widgets, mytempgraph)
uzful.widget.set_properties(mytempgraph, {
    border_color = nil,
    color = "#AA0000",
    background_color = "#000000" })
vicious.register(mytempgraph, vicious.widgets.thermal, "$1", 4, "thermal_zone0")

-- net usage graphs

mynetgraphs = uzful.widget.netgraphs({ default = "wlan0",
    up_fgcolor = "#D0000399", down_fgcolor = "#95D04399",
    up_mgcolor = "#D0000311", down_mgcolor = "#95D04311",
    highlight = ' <b>$1</b>', direction = "right",
    normal    = ' <span color="#666666">$1</span>',
    big = { width = 161, height = 42, interval = 1, scale = "kb" },
    small = { width = 23, height = theme.menu_height, interval = 1 } })

mynetgraphs.update_active()
mynetgraphs.update_widget = function ()
    mynetgraphs.update_active()
    myinfobox.net.height = mynetgraphs.big.height
    myinfobox.net:update()
end
mynetgraphs.small.layout:buttons(awful.util.table.join(
    awful.button({ }, 1, mynetgraphs.toggle),
    awful.button({ }, 2, mynetgraphs.update_widget),
    awful.button({ }, 3, mynetgraphs.toggle),
    awful.button({ }, 4, mynetgraphs.toggle),
    awful.button({ }, 5, mynetgraphs.toggle)
))

for _, widget in ipairs(mynetgraphs.big.widgets) do
    table.insert(detailed_graphs.widgets, widget)
end

-- CPU graphs

mycpugraphs = uzful.widget.cpugraphs({
    fgcolor = "#D0752A", bgcolor = "#000000", direction = "right",
    load = { interval = 20, font = "ProggyTinyTT 10",
        text = ' <span color="#666666">$1</span>' ..
               '  <span color="#9A9A9A">$2</span>' ..
               '  <span color="#DDDDDD">$3</span>' },
    big = { width = 161, height = 42, interval = 1, direction = "left" },
    small = { width = 42, height = theme.menu_height, interval = 1 } })

table.insert(detailed_graphs.widgets, mycpugraphs.load)
for _, widget in ipairs(mycpugraphs.big.widgets) do
    table.insert(detailed_graphs.widgets, widget)
end



-- infoboxes funs

myinfobox = { net = {}, cpu = {}, cal = {}, bat = {}, mem = {}, temp = {}, wifi = {} }

myinfobox.net = uzful.widget.infobox({
        position = "top", align = "right",
        widget = mynetgraphs.big.layout,
        height = mynetgraphs.big.height,
        width = mynetgraphs.big.width })
myinfobox.cpu = uzful.widget.infobox({
        position = "top", align = "right",
        widget = mycpugraphs.big.layout,
        height = mycpugraphs.big.height,
        width = mycpugraphs.big.width })
myinfobox.temp = uzful.widget.infobox({
        size = function () return mytempgraph:fit(-1, -1) end,
        position = "top", align = "right",
        widget = uzful.layout.build({
                widget = mytempgraph,
                reflection = { vertical = true },
                layout = wibox.layout.mirror }) })
myinfobox.cal = uzful.widget.infobox({
        size = function () return mycal.width,mycal.height end,
        position = "top", align = "right",
        widget = mycal.widget })
myinfobox.bat = uzful.widget.infobox({
        size = function () return mybtxt:fit(-1, -1) end,
        position = "top", align = "right",
        widget = mybtxt })
myinfobox.mem = uzful.widget.infobox({
        size = function () return mymtxt:fit(-1, -1) end,
        position = "top", align = "right",
        widget = mymtxt })
if mynettxt then
    myinfobox.wifi = uzful.widget.infobox({
            size = function () return mynettxt:fit(-1, -1) end,
            position = "top", align = "right",
            widget = mynettxt })
end

mynetgraphs.small.layout:connect_signal("mouse::enter", function ()
    if detailed_graphs.visible() then
        myinfobox.net:update()
        myinfobox.net:show()
    end
end)

mycpugraphs.small.layout:connect_signal("mouse::enter", function ()
    if detailed_graphs.visible() then
        myinfobox.cpu:update()
        myinfobox.cpu:show()
    end
end)

mytemp:connect_signal("mouse::enter", function ()
    if detailed_graphs.visible() then
        myinfobox.temp:update()
        myinfobox.temp:show()
    end
end)

mytextclock:connect_signal("mouse::enter", function ()
    mycal:update()
    myinfobox.cal:update()
    myinfobox.cal:show()
end)

mybat:connect_signal("mouse::enter", function ()
    myinfobox.bat:update()
    myinfobox.bat:show()
end)

mymem:connect_signal("mouse::enter", function ()
    myinfobox.mem:update()
    myinfobox.mem:show()
end)

if mynet then
    mynet:connect_signal("mouse::enter", function ()
        myinfobox.wifi:update()
        myinfobox.wifi:show()
    end)
end

mynetgraphs.small.layout:connect_signal("mouse::leave", myinfobox.net.hide)
mycpugraphs.small.layout:connect_signal("mouse::leave", myinfobox.cpu.hide)
mytextclock:connect_signal("mouse::leave", myinfobox.cal.hide)
mytemp:connect_signal("mouse::leave", myinfobox.temp.hide)
mybat:connect_signal("mouse::leave", myinfobox.bat.hide)
mymem:connect_signal("mouse::leave", myinfobox.mem.hide)
if mynet then
    mynet:connect_signal("mouse::leave", myinfobox.wifi.hide)
end




mylayoutmenu = uzful.menu.layouts(layouts, { align = "right", width = 60 })

-- Create a wibox for each screen and add it
mywibox = {}
mynotification = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients(nil,{theme={width=250}})
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 2, function () mylayoutmenu:toggle() end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, taglist_filter.call, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create a notification manager widget
    mynotification[s] = uzful.notifications(s, {
        max = screen[s].workarea.height - theme.menu_height,
        menu = { theme = { width = 342 } },
        text = '<span size="small">$1</span>' })

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = theme.menu_height })


    if myrestorelist[s].length > 0 then
        myrestorelist[s].widget = uzful.widget.infobox({ screen = s,
                size = myrestorelist[s].fit,
                position = "top", align = "left",
                visible = true, ontop = false,
                widget = myrestorelist[s].layout })
        myrestorelist[s].layout:connect_signal("widget::updated", function ()
            if myrestorelist[s].length == 0 then
                myrestorelist[s].widget:hide()
                myrestorelist[s].widget.screen = nil
            else
                myrestorelist[s].widget:update()
            end
        end)
    end

    local layout = uzful.layout.build({
        layout = wibox.layout.align.horizontal,
        left = { layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            mytaglist[s],
            mypromptbox[s] },
        middle = mytasklist[s],
        right = { layout = wibox.layout.fixed.horizontal,
            function () return s == SCREEN.LVDS1 and wibox.widget.systray() or nil end,
            mynotification[s].text,
            mynetgraphs.small.layout,
            mycpugraphs.small.layout,
            mytemp,
            mytextclock,
            mynet,
            mybat,
            mymem,
            mylayoutbox[s] }
    })

    mywibox[s]:set_widget(layout)


    mynotification[s].text:buttons(awful.util.table.join(
        awful.button({ }, 1, function () mynotification[s]:toggle_menu() end),
        awful.button({ }, 3, function () mynotification[s]:toggle() end)
    ))
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
if syslog_enabled then
    mysyslogtext:buttons(awful.util.table.join(
        awful.button({ }, 3, function () mymainmenu:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
    ))
end
-- }}}

volume = {
    master = {
        lower  = function (x) couth.notifier:notify( couth.alsa:setVolume('Master',(x or 2)..'dB-')) end,
        raise  = function (x) couth.notifier:notify( couth.alsa:setVolume('Master',(x or 2)..'dB+')) end,
        toggle = function ()  couth.notifier:notify( couth.alsa:setVolume('Master','toggle'))        end,
    },
    pcm = {
        lower  = function (x) couth.notifier:notify( couth.alsa:setVolume('PCM',(x or 2)..'dB-')) end,
        raise  = function (x) couth.notifier:notify( couth.alsa:setVolume('PCM',(x or 2)..'dB+')) end,
        toggle = function ()  couth.notifier:notify( couth.alsa:setVolume('PCM','toggle'))        end,
    },
}
backlight = {
    lighten  = function (x) couth.notifier:notify( couth.back:setLight( x or 10)) end,
    darken   = function (x) couth.notifier:notify( couth.back:setLight((x or 10) * -1)) end,
}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({}, "XF86Launch1",     lock),
    awful.key({}, "XF86ScreenSaver", lock),
    awful.key({}, "#149",            invert_screen),

    keydoc.group("tag management"),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       , "previous"),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       , "next"),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore, "restore"),

    keydoc.group("focus"),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,"urgent window"),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, "previously focused window"),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end, "next window"),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end, "previous window"),
    awful.key({ modkey,           }, "a", function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients(nil,
                    { keygrabber = true, theme = { width = 250 } } )
            end
        end, "choose from list"),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end, "next screen"),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end, "previous screen"),

    keydoc.group("layout manipulation"),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,"swap with next window"),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,"swap with previous window"),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end, "increase master width factor"),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end, "decrease master width factor"),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end, "increase number of masters"),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end, "decrease number of masters"),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end, "increase number of columns"),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end, "decrease number of columns"),
    awful.key({ modkey, "Control" }, "r",     uzful.layout.reset, "reset layout back to defaults"),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end, "next layout"),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end, "previous layout"),

    keydoc.group("control sound"),
    awful.key({ modkey            }, "<",            volume.master.lower, "lower master"),
    awful.key({ modkey, "Shift"   }, "<",            volume.master.raise, "raise master"),
    awful.key({}, "XF86AudioLowerVolume",            volume.master.lower),
    awful.key({}, "XF86AudioRaiseVolume",            volume.master.raise),
    awful.key({}, "XF86AudioMute",                   volume.master.toggle),
    awful.key({ "Control", modkey            }, "<", volume.pcm.lower, "lower pcm"),
    awful.key({ "Control", modkey, "Shift"   }, "<", volume.pcm.raise, "raise pcm"),
    awful.key({ "Control" }, "XF86AudioLowerVolume", volume.pcm.lower),
    awful.key({ "Control" }, "XF86AudioRaiseVolume", volume.pcm.raise),
    awful.key({ "Control" }, "XF86AudioMute",        volume.pcm.toggle),
    awful.key({ "Shift" }, "XF86AudioLowerVolume", function () volume.master.lower(5) end),
    awful.key({ "Shift" }, "XF86AudioRaiseVolume", function () volume.master.raise(5) end),
    awful.key({ "Control", "Shift" }, "XF86AudioLowerVolume", function () volume.pcm.lower(5) end),
    awful.key({ "Control", "Shift" }, "XF86AudioRaiseVolume", function () volume.pcm.raise(5) end),

    keydoc.group("misc"),
    awful.key({}, "XF86MonBrightnessDown", backlight.darken,  "darken backlight" ),
    awful.key({}, "XF86MonBrightnessUp",   backlight.lighten, "lighten backlight"),
    awful.key({ "Shift" }, "XF86MonBrightnessDown", function () backlight.darken( 20) end),
    awful.key({ "Shift" }, "XF86MonBrightnessUp",   function () backlight.lighten(20) end),

    awful.key({ modkey,           }, "Print",  screenshot,"screenshot"),
    awful.key({ modkey,           }, "w", function ()
            local g = screen[mouse.screen].geometry
            mymainmenu:toggle({
                coords = {
                    x = g.x + math.floor(g.width  * 0.5) - 8,
                    y = g.y + math.floor(g.height * 0.5) - 8
                },
                keygrabber = true })
        end, "menu"),
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end, "spawn terminal"),
    awful.key({ modkey, "Shift", "Control" }, "r", awesome.restart,"restart awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit, "quit awesome"),

    -- Prompt
    awful.key({ modkey,           }, "r",     function () mypromptbox[mouse.screen]:run() end, "prompt"),
    awful.key({ modkey, "Shift"   }, "r",     function () menubar.show(mouse.screen) end, "menubar"),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end, "run lua")
)

clientkeys = awful.util.table.join(
    keydoc.group("window specific"),
    awful.key({ modkey, "Control", "Shift" },  "space", uzful.widget.titlebar.mirror, "mirror titlebar"),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end, "fullscreen"),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end, "kill"),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end, "kill"),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     , "toggle floating"),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, "get master"),
    awful.key({ modkey,           }, "o",      function(c) awful.client.movetoscreen(c,c.screen-1) end, "move to previous screen"),
    awful.key({ modkey,           }, "p",      function(c) awful.client.movetoscreen(c,c.screen+1) end, "move to next screen"),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end, "toggle ontop"),
    awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky          end, "toggle sticky"),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end, "minimize"),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end, "toggle maximized"),
    awful.key({ modkey,           }, "g",
        function (c)
            uzful.groups.create(awful.layout.suit.fair, c)
        end)
)

globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey, "Control" }, "n", function () awful.client.restore() end, "restore minimized"))


-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
    keynumber = math.min(20, math.max(#tags[s], keynumber))

    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "F" .. s,
            function ()
                awful.screen.focus(s)
            end))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i].selected then
                            return awful.tag.history.restore()
                        end
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "mplayer2" },
      properties = { floating = true } },
    { rule = { class = "lastfm" },
      properties = { floating = true } },
    { rule = { class = "feh" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 1 of screen 1.
     { rule = { class = "Firefox" },
       properties = { tag = tags[1][1] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    c.opacity = 1
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    local bar = uzful.widget.titlebar(c)
    bar.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.mouse.client.move(c)   end),
        awful.button({ }, 3, function () awful.mouse.client.resize(c) end)))

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
            awful.button({ }, 1, function () awful.mouse.client.move(c)   end),
            awful.button({ }, 3, function () awful.mouse.client.resize(c) end)))
        local rotation = wibox.layout.rotate()
        rotation:set_direction("east")
        rotation:set_widget(uzful.layout.build({
            layout = wibox.layout.align.horizontal,
            middle = title,
            left = { layout = wibox.layout.fixed.horizontal,
                awful.titlebar.widget.iconwidget(c) },
            right = { layout = wibox.layout.fixed.horizontal,
                awful.titlebar.widget.stickybutton(c),
                awful.titlebar.widget.ontopbutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.closebutton(c) }
        }))
        awful.titlebar(c, {
            size = theme.menu_height,
            position = "left"
        }):set_widget(rotation)
    end

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus",   function(c)
    c.border_color = beautiful.border_focus
    --c.opacity = 1
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    --c.opacity = 0.5
end)

require("autostart")

