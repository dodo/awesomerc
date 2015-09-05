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
}

