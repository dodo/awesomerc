return {
    launcher = true, -- show awesome button for main menu
    battery = false, -- show notebook battery
    graphs = false, --  show detailed graphs
    phone = false, -- or 'kdeconnect.device.id' or {ids…} -- show phone battery
    sysfs = false, -- listen to sysfs events
    cpu = false, -- show cpu stats
    clock = false, -- show a clock
    freedekstop = false, -- show freedekstop menu
    mpris = true, -- use mpris client
    memory = false, -- show memory usage
    monitor = false, -- show monitor change notifications
    calendar = false, -- show calendar when hovering clock
    keyboard = true, -- show keyboard map indicator and switcher
    temperature = false, -- show cpu temperature stats
    restore = false, -- enable restoring window stats and tag settings
    network = false, -- or true -- show network & wire stats from wicd via dbus or show at least network stats if true
    notifications = false, -- widget to block notifications and store a history of them
    syslog = false, --uzful.util.module.exists('inotify') and uzful.util.module.exists('socket'),
    dbus = not not dbus,
    default_layout = 'floating', -- name or index of awful.layout.layouts
    tags = 'number', -- or 'number' -- tag name style default
    taglist = 'all', -- or 'all' -- talist filter default
    titlebars = 'left', -- or 'left' or 'right' or 'top' or 'bottom' or false -- titlebar attachment behavior
}
