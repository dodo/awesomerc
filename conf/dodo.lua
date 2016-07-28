local dir = awful.util.getdir("config") .. "/theme/"

return {
    launcher = false, -- show awesome button for main menu
    battery = true, -- show notebook battery
    graphs = true, --  show detailed graphs
    phone = {'ae28d977c3c41ed6', '5608e506aeee6824','3d2a954efce5f5ba'}, -- show phone battery
    sysfs = true, -- listen to sysfs events
    cpu = true, -- show cpu stats
    clock = true, -- show a clock
    mpris = uzful.util.module.exists('lua-mpris'), -- use mpris client
    memory = true, -- show memory usage
    monitor = true, -- show monitor change notifications
    calendar = true, -- show calendar when hovering clock
    keyboard = true, -- show keyboard map indicator and switcher
    temperature = true, -- show cpu temperature stats
    restore = true, -- enable restoring window stats and tag settings
    network = 'wicd', -- or true -- show network & wire stats from wicd via dbus or show at least network stats if true
    notifications = true, -- widget to block notifications and store a history of them
    syslog = uzful.util.module.exists('inotify') and uzful.util.module.exists('socket'),
    dbus = not not dbus and uzful.util.module.exists('lua-dbus'),
    tags = 'symbol', -- or 'number' -- tag name style default
    taglist = 'noempty', -- or 'all' -- talist filter default
    titlebars = 'ontop', -- or 'left' or 'right' or 'top' or 'bottom' or false -- titlebar attachment behavior
    animation = true,
    autostart = {
      -- "unagi" -- http://unagi.mini-dweeb.org/
      "akonaditray",
      "zeal",
    },
    wallpapers = {
        { dir .. "icons/awesome16.png", center = true},
        {"/home/dodo/Pictures/7003_68fd_black.png", center = true},
        {"/home/dodo/Pictures/minimalcluster1900x1080.png", center = true},
        {"/home/dodo/Pictures/minimalblueprint1900x1080.png", center = true},
        {"/home/dodo/Pictures/blue_print_desktop_1600x1200_tranformed.jpg", maximize=true},
        {"/home/dodo/Pictures/161502-strutingcolours.jpg", maximize=true},
        {"/home/dodo/Pictures/meh.ro9016.png", center = true},
        "/home/dodo/Pictures/into_the_woods_1280x800.jpg",
        "/home/dodo/Pictures/planetoid_3_1280x800.png",
        "/home/dodo/Pictures/meh.ro7944.png",
        "/home/dodo/Pictures/meh.ro2263.png",
        "/home/dodo/Pictures/meh.ro3274.jpg",
    }
}
