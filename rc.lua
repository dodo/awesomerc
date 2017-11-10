pcall(require, "luarocks.loader")

gears = require("gears")
awful = require("awful")
wibox = require("wibox")

local timer = (type(timer) == 'table' and timer or require("gears.timer"))

-- set the loading wallpaper. this will be replaced by the first entry after loading, but without
-- we get corruption of the root window buffer which causes ugly artifacts if the background entries
-- are wrong
local function loading(state)
    local loading_image = awful.util.getdir("config") .. "/theme/" .. state .. ".png"
    for s = 1, screen.count() do
        gears.wallpaper.centered(loading_image, s, "#000000")
    end
end

loading "animation/load"

-- usefull for debugging
-- inspect = require('inspect')

-- Standard awesome library
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")
awful.spawn = require("awful.spawn")
-- Theme handling library
beautiful = require("beautiful")
icon_theme = require('menubar.icon_theme')
-- Notification library
naughty = require("naughty")
menubar = require("menubar")
keydoc = require("keydoc")
hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Widget library
vicious = require("vicious")
-- Load Debian menu entries
--require("debian.menu")
-- utils Library
_, luadbus = pcall(require, "lua-dbus")
utilz = require("utilz")
uzful = require("uzful")
-- keyboard mouse control
if uzful.util.module.exists(package, "rodentbane") then
    require("rodentbane")
end
-- audio control
couth = require("couth")
require("couth.lib.alsa")
couth.CONFIG.ALSA_CONTROLS = {
    'Master',
    'PCM',
}
require("backlight") -- uses couch too


beautiful.init(awful.util.getdir("config") .. "/theme.lua")
theme.icons = icon_theme()

myscreensmenu = uzful.menu.xrandr({
        -- order
        "LVDS1", "HDMI1", "VGA1",
        -- names
        LVDS1 = "Local",
        HDMI1 = "DP++",
        VGA1  = "VGA",
}, { icons = theme.randr })
SCREEN = myscreensmenu.const()


rc = { conf = require("conf") }
rc.conf.default_layout = rc.conf.default_layout or 'floating'

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
uzful.notifications.debug()
uzful.notifications.patch()
uzful.util.patch.vicious()
uzful.util.patch.naughty()

menubar.cache_entries = true
menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu
menubar.geometry.height = theme.menu_height
uzful.widget.repl.geometry.height = theme.menu_height

-- vicious caching
vicious.cache(vicious.widgets.thermal)
vicious.cache(vicious.widgets.net)

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Load freedesktop menu
if rc.conf.freedesktop then
    freedesktop = require('freedesktop')
end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
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


-- {{{ Tags
-- Define a tag table which hold all screen tags.
--tags = {}
tag_names = {"☼", "✪", "⌥", "✇", "⌤", "⍜", "⌬", "♾", "⌘", "⚗", "Ω", "·"}
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu


detailed_graphs = uzful.menu.toggle_widgets()
if not rc.conf.graphs then detailed_graphs.toggle() end

myfreedesktopmenu = freedesktop and freedesktop.menu.build{icon_size = theme.menu_height}

mylayoutmenu = uzful.menu.layouts(awful.layout.layouts, { align = "right", width = 60 })
mylayoutmenu:add({ "actions", uzful.menu.tag_info({ default = rc.conf.default_layout, layouts = awful.layout.layouts, theme = { width = 150 } }) })

mysystemmenu = {}
unagi         = function () awful.spawn.with_shell("unagi")             end
lock          = function () awful.spawn.with_shell("xtrlock")           end
screenshot    = function () awful.spawn("ksnapshot")                    end
invert_screen = function () awful.spawn("xcalib -invert -alter", false) end
table.insert(mysystemmenu, { "invert screen", invert_screen })
table.insert(mysystemmenu, { "screenshot", screenshot })
table.insert(mysystemmenu, { "lock", lock })
if rc.conf.dbus then
    table.insert(mysystemmenu, { "suspend", function ()
        naughty.notify({ text = "system suspsending  ... " })
        awful.spawn.with_shell("sync && dbus-send --system --print-reply --dest='org.freedesktop.UPower' /org/freedesktop/UPower org.freedesktop.UPower.Suspend & xtrlock")
    end })
end

taglist_filter = uzful.util.functionlist({
    awful.widget.taglist.filter.noempty,
    awful.widget.taglist.filter.all })
if rc.conf.taglist == 'all' then taglist_filter.next() end

mywallpapermenu = uzful.menu.wallpaper.menu(rc.conf.wallpapers or theme.default_wallpapers)

myawesomemenu = {
   { "system", mysystemmenu },
   { "second screen", myscreensmenu },
   { "wallpapers", mywallpapermenu },
   { "layouts", mylayoutmenu.menu_switch },
   uzful.menu.switch.naughty(),
   uzful.menu.switch.filter({
       filter = taglist_filter,
       labels = {
           "show all tags",
           "hide empty tags",
       },
   }),
   uzful.menu.switch.numbered_tag_names({
       numbered = (rc.conf.tags == 'number'),
       names = tag_names,
       label = { named = "symbol" },
   }),
   uzful.menu.switch.toggle({
       test  = detailed_graphs.visible,
       toggle = detailed_graphs.toggle,
       labels = {
           [true]  = "disable graphs",
           [false] = "enable graphs",
       },
   }),
   { "console", function () uzful.widget.repl.show(mouse.screen, { prompt = theme.prompt.lua }) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "keybindings", keydoc.display },
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "restart", awesome.restart },
   { "quit", function () awesome.quit() end },
}

do local items = {max = 100}
items[1] = { "awesome", myawesomemenu, beautiful.awesome_icon }
if freedesktop then items[#items+1] = { "applications", {"foo","bar"}, theme.icons:find_icon_path('debian-logo',theme.menu_height)} end
items[#items+1] = { "open terminal", terminal, theme.icons:find_icon_path('utilities-terminal',theme.menu_height) }
mymainmenu = awful.menu(items)
if freedesktop then mymainmenu.child[2], myfreedesktopmenu.parent = myfreedesktopmenu, mymainmenu end
--mymainmenu = awful.menu({ max = 100,
--    { "awesome", myawesomemenu, beautiful.awesome_icon },
--    (myfreedesktopmenu and { "Menu", myfreedesktopmenu, 'debian-logo'} or false),
--    { "open terminal", terminal, 'terminal' },
--    { "Menu", myfreedesktopmenu, freedesktop.utils.lookup_icon({ icon = 'kde' }) },
--    { "Debian", debian.menu.Debian_menu.Debian, freedesktop.utils.lookup_icon({ icon = 'debian-logo' }) },
--    { "open terminal", terminal, freedesktop.utils.lookup_icon({ icon = 'terminal' }) },
--                        })
end

if rc.conf.syslog then
    -- luarocks install inotify INOTIFY_INCDIR=/usr/include/x86_64-linux-gnu
    mysyslog = uzful.widget.syslog({
        screen = SCREEN.LVDS1,
        lines = theme.syslog_lines or 64,
        fg = theme.syslog_fg,
        bg = theme.syslog_bg,
        logs = {
            syslog = { file = "/var/log/syslog" },
--             xsessionerrors = { file = "/home/dodo/.xsession-errors" },
        },
    })
end

mylauncher = nil
if rc.conf.launcher then
    mylauncher = awful.widget.launcher({
        image = beautiful.awesome_icon,
        menu = mymainmenu,
    })
end

mympris = nil
if rc.conf.dbus and rc.conf.mpris then
    mympris = uzful.widget.mpris({
        theme = theme.mpris,
        lookup_icon = function (name)
            return theme.icons:find_icon_path(name, theme.menu_height)
        end,
    })
end
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = nil
if rc.conf.clock then
    mytextclock = wibox.widget.textclock(' %H:%M ')
    mytextclock:set_font("sans 4")
end

mycal = nil
if rc.conf.clock and rc.conf.calendar then
    mycal = uzful.widget.calendar({ 
        font = 7, screen = 1,
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
end

-- Keyboard map indicator and switcher
mykeyboardlayout = nil
if rc.conf.keyboard then
    mykeyboardlayout = awful.widget.keyboardlayout()
    print("keyboard layouts: " .. table.concat(mykeyboardlayout._layout, ', '))
    print("keyboard layout group names: " .. awesome.xkb_get_group_names())
end

-- Memory Progressbar
mymem = nil
if rc.conf.memory then
    mymem = uzful.widget.progressimage({
        x = 2, y = 2, width = 5, height = 10, vertical = true,
        image = theme.memory, draw_image_first = false })
    uzful.widget.set_properties(mymem.progress, {
        background_color = "#000000",
        border_color = nil, color = "#0173FF" })
    --mymem:set_color({ "#001D40", "#535d6c", "#0173FF" })
    vicious.register(mymem.progress, vicious.widgets.mem, "$1", 4)
    -- Memory Text
    mymem.text = wibox.widget.textbox()
    mymem.text:set_font(theme.widget_font .. " 7")
    vicious.register(mymem.text, vicious.widgets.mem,
        '$4mb free, $1%', 60)
end

-- Battery Progressbar
mybattery = nil
if rc.conf.sysfs and rc.conf.battery then
    mybattery = uzful.widget.battery({
        bat = 'BAT0', ac = 'AC',
        x = 3, y = 4, width = 3, height = 7, -- matching theme/battery.png
        theme = theme, font = theme.widget_font .. " 7",
    })
end


if rc.conf.sysfs and rc.conf.monitor then
    -- reuse mybattery.timer here
    local bat = mybattery or {}
    bat.timer = uzful.util.listen.sysfs({ subsystem = "drm", timer = bat.timer },
                                    function (device, props)
        if props.action == "change" and props.devtype == "drm_minor" and screen.count() > 1 then
            naughty.notify({
                timeout = 0,
                hover_timeout = 0.1,
                position = "bottom_right",
                icon = theme.nomonitor })
        end
    end).timer
end


myphones = nil
if rc.conf.dbus and rc.conf.phone then
    myphones = {}
    local phones = rc.conf.phone
    if type(phones) ~= 'table' then
        phones = {phones}
    end
    for _, phone in ipairs(phones) do
        local myphone = uzful.widget.battery.phone({ id = phone,
            x = 3, y = 5, width = 2, height = 5, -- matching theme/phone/battery.png
            theme = theme.phone, font = theme.widget_font .. " 7",
        })
        myphone.notifications = uzful.notifications.phone(myphone.id)
        myphone.widget:buttons(awful.util.table.join(
            awful.button({ }, 1, function () myphone.notifications:toggle() end)
        ))
        table.insert(myphones, myphone)
    end
end

mytemp = nil
if rc.conf.temperature then
    -- Temperature Info
    mytemp = uzful.widget.temperature({
        width = 161, height = 42,
        font = "sans 5",
    })
    table.insert(detailed_graphs.widgets, mytemp.graph)
    vicious.register(mytemp.notifications, vicious.widgets.thermal, "$1", 30, "thermal_zone0")
    vicious.register(mytemp.graph,         vicious.widgets.thermal, "$1",  4, "thermal_zone0")
end

-- net usage graphs
mynetgraphs = nil
if rc.conf.network then
    mynetgraphs = uzful.widget.netgraphs({ default = rc.conf.wireless or "wlan0",
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
        if myphones then
            for _, myphone in ipairs(myphones) do
                myphone.update()
            end
        end
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
end

-- Network Progressbar
mynet = nil
if rc.conf.dbus and rc.conf.network == 'wicd' then
    mynet = uzful.widget.wicd({
        x = 1, y = 2, width = 3, height = 9,
        theme = theme.wicd, font = theme.widget_font .. " 7",
        onupdate = mynetgraphs.update_widget,
        onconnect = function (kind)
            if kind == "wireless" then
                mynetgraphs.switch(rc.conf.wireless or "wlan0")
            elseif kind == "wired" then
                mynetgraphs.switch(rc.conf.wired or "eth0")
            end
            mynetgraphs.update_widget()
        end,
        ondisconnect = function ()
            mynetgraphs.update_widget()
            if myphones then
                for _, myphone in ipairs(myphones) do
                    myphone.widget.hide()
                end
            end
        end,
    })
end

-- CPU graphs

if rc.conf.cpu then
    mycpugraphs = uzful.widget.cpugraphs({
        fgcolor = "#D0752A", bgcolor = "#000000", direction = "right",
        load = { interval = 30, font = theme.widget_font .. " 10",
            text = ' <span color="#666666">$1</span>' ..
                '  <span color="#9A9A9A">$2</span>' ..
                '  <span color="#DDDDDD">$3</span>' },
        big = { width = 161, height = 42, interval = 1, direction = "left" },
        small = { width = 42, height = theme.menu_height, interval = 1 } })

    table.insert(detailed_graphs.widgets, mycpugraphs.load)
    for _, widget in ipairs(mycpugraphs.big.widgets) do
        table.insert(detailed_graphs.widgets, widget)
    end
end

-- infoboxes funs
myinfobox = { net = {}, cpu = {}, cal = {}, bat = {}, mem = {}, temp = {}, wifi = {} }
myinfobox.phones = {}

local function widget_fit_maxsize(a) return a.widget:get_preferred_size(1) end

if mynetgraphs then
    myinfobox.net = uzful.widget.infobox({
        position = "top", align = "right",
        widget = mynetgraphs.big.layout,
        height = mynetgraphs.big.height,
        width = mynetgraphs.big.width })
end
if mycpugraphs then
    myinfobox.cpu = uzful.widget.infobox({
        position = "top", align = "right",
        widget = mycpugraphs.big.layout,
        height = mycpugraphs.big.height,
        width = mycpugraphs.big.width })
end
if mytemp then
    myinfobox.temp = uzful.widget.infobox({
        size = function () return mytemp.graph:get_width(), mytemp.graph:get_height() end,
        position = "top", align = "right",
        widget = wibox.container.mirror(mytemp.graph, { horizontal = true }) })
end
if mycal then
    myinfobox.cal = uzful.widget.infobox({
        size = function () return mycal.width,mycal.height end,
        position = "top", align = "right",
        widget = mycal.widget })
end
if mybattery then
    myinfobox.bat = uzful.widget.infobox({
        size = widget_fit_maxsize,
        position = "top", align = "right",
        widget = mybattery.text })
end
if mymem then
    myinfobox.mem = uzful.widget.infobox({
        size = widget_fit_maxsize,
        position = "top", align = "right",
        widget = mymem.text })
end
if myphones then
    for _, myphone in ipairs(myphones) do
        table.insert(myinfobox.phones, {
            widget = myphone.widget,
            bat = uzful.widget.infobox({
                size = widget_fit_maxsize,
                position = "top", align = "right",
                widget = myphone.text }),
        })
    end
end
if mynet then
    myinfobox.wifi = uzful.widget.infobox({
        size = widget_fit_maxsize,
        position = "top", align = "right",
        widget = mynet.text })
end

do local _ = utilz.connect_graph_on_mouse_enter -- (widget, box, toggle)
    if mynetgraphs then _(mynetgraphs.small.layout, myinfobox.net, detailed_graphs) end
    if mycpugraphs then _(mycpugraphs.small.layout, myinfobox.cpu, detailed_graphs) end
    if mytemp then _(mytemp.text, myinfobox.temp, detailed_graphs) end
end

do local _ = utilz.connect_update_on_mouse_enter -- (widget, box, updatables...)
    if mycal then _(mytextclock, myinfobox.cal, mycal) end
    if mymem then _(mymem, myinfobox.mem) end
    if mynet then _(mynet.widget, myinfobox.wifi) end
    if mybattery then _(mybattery.widget, myinfobox.bat) end
    if myphones then
        for i, phone in ipairs(myinfobox.phones) do
            _(phone.widget, phone.bat)
        end
    end
end

-- Create a wibox for each screen and add it
--mywibox = {}
--mynotification = {}
--mypromptbox = {}
--mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (t) t:view_only() end),
    awful.button({ modkey }, 1, function (t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function (t)
        if client.focus then client.focus:toggle_tag(t) end
    end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c.minimized = false
            if not c:isvisible() then
                c.first_tag:view_only()
            end
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 2, function ()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = uzful.menu.daemons({theme={width=250}})
        end
    end),
    awful.button({ }, 3, function ()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = uzful.menu.clients({theme={width=250}})
        end
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end)
)

awful.screen.connect_for_each_screen(function(s)
    awful.tag(tag_names, s, uzful.layout.get(rc.conf.default_layout))
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt({ prompt = theme.prompt.cmd })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                          awful.button({ }, 1, function () awful.layout.inc( 1) end),
                          awful.button({ }, 2, function () mylayoutmenu:toggle() end),
                          awful.button({ }, 3, function () awful.layout.inc(-1) end),
                          awful.button({ }, 4, function () awful.layout.inc( 1) end),
                          awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, taglist_filter.call, mytaglist.buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create a notification manager widget
    if rc.conf.notifications then
        s.mynotification = uzful.notifications(s, {
            max = s.workarea.height - theme.menu_height,
            menu = { theme = { width = 342 } },
            text = '<span size="small">$1</span>' })
    end

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = theme.menu_height })


--    if myrestorelist and myrestorelist[s] and myrestorelist[s].length > 0 then
--        myrestorelist[s].widget = uzful.widget.infobox({ screen = s,
--                size = myrestorelist[s].fit,
--                position = "top", align = "left",
--                visible = true, ontop = false,
--                widget = myrestorelist[s].layout })
--        myrestorelist[s].layout:connect_signal("widget::updated", function ()
--            if myrestorelist[s].length == 0 then
--                myrestorelist[s].widget:hide()
--                myrestorelist[s].widget.screen = nil
--            else
--                myrestorelist[s].widget:update()
--            end
--        end)
--    end

    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        { layout = wibox.layout.fixed.horizontal, -- left
            mylauncher or nil,
            mympris or nil,
            s.mytaglist,
            s.mypromptbox },
        s.mytasklist, -- middle
        awful.util.table.join({ layout = wibox.layout.fixed.horizontal, -- right
            (function () return s == SCREEN.LVDS1 and wibox.widget.systray() or nil end)(),
            mykeyboardlayout or nil,
            s.mynotification and s.mynotification.text or nil,
            mynetgraphs and mynetgraphs.small.layout or nil,
            mycpugraphs and mycpugraphs.small.layout or nil,
            mytemp and mytemp.text or nil,
            mytextclock or nil,
            mynet and mynet.widget or nil,
            }, uzful.util.table.map(myphones or {}, function (myphone)
                return myphone and myphone.widget or nil
            end), {
            mybattery and mybattery.widget or nil,
            mymem or nil,
            s.mylayoutbox })
    })


    if s.mynotification then
        s.mynotification.text:buttons(awful.util.table.join(
            awful.button({ }, 1, function () s.mynotification:toggle_menu() end),
            awful.button({ }, 3, function () s.mynotification:toggle() end)
        ))
    end
end)

myrestorelist = nil
if rc.conf.restore then
    uzful.restore = require("uzful.restore")
    local opts = type(rc.conf.restore) == 'table' and rc.conf.restore or {}
    local ok, myrestorelist = pcall(uzful.restore, opts)
    if not ok then
        local err = tostring(myrestorelist)
        myrestorelist = nil
        print("myrestorelist errored:", err)
        naughty.notify({ text = err,
            title = "Oops, there were errors during startup!",
            preset = naughty.config.presets.critical })
    end
end

-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
if rc.conf.syslog then
    uzful.widget.syslog.get_text(mysyslog):buttons(awful.util.table.join(
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
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end, "next layout"),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end, "previous layout"),

    keydoc.group("control sound"),
    awful.key({ modkey            }, "<",            volume.master.lower, "lower master"),
    awful.key({ modkey, "Shift"   }, "<",            volume.master.raise, "raise master"),
    awful.key({}, "XF86AudioLowerVolume",            volume.master.lower),
    awful.key({}, "XF86AudioRaiseVolume",            volume.master.raise),
    awful.key({}, "XF86AudioMute",                   volume.master.toggle),
    awful.key({}, "XF86AudioStop", function () if mympris then mympris:stop() end end),
    awful.key({}, "XF86AudioNext", function () if mympris then mympris:next() end end),
    awful.key({}, "XF86AudioPrev", function () if mympris then mympris:previous() end end),
    awful.key({}, "XF86AudioPlay", function () if mympris then mympris:playpause() end end),
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
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end, "spawn terminal"),
    awful.key({ modkey, "Shift", "Control" }, "r", awesome.restart,"restart awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit, "quit awesome"),

    -- Prompt
    awful.key({ modkey,           }, "r",     function () mouse.screen.mypromptbox:run() end, "prompt"),
    awful.key({ modkey, "Shift"   }, "r",     function () menubar.show(mouse.screen) end, "menubar"),
    awful.key({ modkey, "Shift"   }, "x",     function () uzful.widget.repl.show(mouse.screen, { prompt = theme.prompt.lua }) end, "repl"),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = theme.prompt.lua },
                  mouse.screen.mypromptbox.widget,
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
    awful.key({ modkey, "Control" }, "space",  function (c) awful.client.floating.toggle(c)  end, "toggle floating"),
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


-- Compute the maximum number of digit we need
keynumber = #tag_names
for s = 1, screen.count() do
--    keynumber = math.max(keynumber, #tag_names)

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
                      local tag = awful.screen.focused().tags[i]
                      if tag and tag.selected then
                          return awful.tag.history.restore()
                      end
                      if tag then tag:view_only() end
                  end),
        awful.key({ modkey, "Mod1" }, "#" .. i + 9,
                  function ()
                      uzful.client.focus.byabsidx(i)
                      if client.focus then client.focus:raise() end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local tag = awful.screen.focused().tags[i]
                      if tag then awful.tag.viewtoggle(tag) end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then client.focus:move_to_tag(tag) end
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then client.focus:toggle_tag(tag) end
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
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     screen = awful.screen.preferred,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    -- Floating clients.
    { rule_any = { 
      instance = {"pinentry","copyq","DTA"},
      class = {"mplayer2" ,"mpv","xlogo","qlua","vlc","feh","Inkview","Skype","Hamster-time-tracker","Kruler"},
      name = {"Event Tester"},
      role = {"pop-up","AlarmWindow","ConfigManager"},
    }, properties = { floating = true, titlebars_enabled = true } },
    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
     }, properties = { titlebars_enabled = true }
   },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    c.opacity = 1
    if awesome.startup then
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

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    local mouse_buttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.mouse.client.move(c)   end),
        awful.button({ }, 3, function () awful.mouse.client.resize(c) end))
    local layout = {
        layout = wibox.layout.align.horizontal,
        { layout = wibox.layout.fixed.horizontal, -- left
            buttons = mouse_buttons,
            awful.titlebar.widget.iconwidget(c) },
        awful.titlebar.widget.titlewidget(c), -- middle
        { layout = wibox.layout.fixed.horizontal, -- right
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.closebutton(c) }
    }
    layout[2]:buttons(mouse_buttons)

    if rc.conf.titlebars == 'ontop' then
        uzful.widget.titlebar(c, {
            size = theme.menu_height,
        }):setup(layout)
    elseif rc.conf.titlebars then
        awful.titlebar(c, {
            size = theme.menu_height,
            position = rc.conf.titlebars,
        }):setup({
            layout,
            layout = wibox.container.rotate,
            direction = (({
                top = "north",
                bottom = "north",
                left = "east",
                right = "west",
            })[rc.conf.titlebars])
        })
    end
end)

-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
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



if rc.conf.animation then
    local animation = timer({timeout = 0.1})
    local frame = 0
    animation:connect_signal('timeout', function ()
        frame = frame + 1
        print("animating …", frame)
        if frame < 11 then
            loading(string.format("animation/%02d", frame))
        elseif frame == 11 then
            loading "icons/awesome16"
        elseif frame == 16 then
            -- we now load the first, aka default background
            if #mywallpapermenu > 0 then
                uzful.menu.wallpaper.set_wallpaper(mywallpapermenu[1]._item or mywallpapermenu[2]._item)
            end
            animation:stop()
            print("animation finished")
        elseif frame > 16 then
            animation:stop()
            print("animation stopped")
        end
    end)
    animation:start()
else
    -- we now load the first, aka default background
    if #mywallpapermenu > 0 then
        uzful.menu.wallpaper.set_wallpaper(mywallpapermenu[1]._item or mywallpapermenu[2]._item)
    end
end

require("autostart")
