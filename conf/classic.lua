return {
    launcher = true, -- show awesome button for main menu
    battery = false, -- show notebook battery
    graphs = false, --  show detailed graphs
    phone = false, -- show phone battery
    sysfs = false, -- listen to sysfs events
    cpu = false, -- show cpu stats
    clock = false, -- show a clock
    mpris = true, -- use mpris client
    memory = false, -- show memory usage
    monitor = false, -- show monitor change notifications
    calendar = false, -- show calendar when hovering clock
    temperature = false, -- show cpu temperature stats
    restore = false, -- enable restoring window stats and tag settings
    network = false, -- or true -- show network & wire stats from wicd via dbus or show at least network stats if true
    notifications = false, -- widget to block notifications and store a history of them
    syslog = false, --uzful.util.module.exists('inotify') and uzful.util.module.exists('socket'),
    dbus = not not dbus,
    tags = 'number', -- or 'number' -- tag name style default
    taglist = 'all', -- or 'all' -- talist filter default
    titlebars = 'left', -- or 'left' or 'right' or 'top' or 'bottom' or false -- titlebar attachment behavior
}
