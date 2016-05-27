local utilz = {}

function utilz.connect_graph_on_mouse_enter(widget, box, toggle)
    widget:connect_signal("mouse::leave", box.hide)
    widget:connect_signal("mouse::enter", function ()
        if toggle.visible() then
            box:update()
            box:show()
        end
    end)
end

function utilz.connect_update_on_mouse_enter(widget, box, ...)
    local widgets = {...}
    widget:connect_signal("mouse::leave", box.hide)
    widget:connect_signal("mouse::enter", function ()
        for _, w in ipairs(widgets) do
            w:update()
        end
        box:update()
        box:show()
    end)
end

function utilz.hostname()
  local f = io.open("/proc/sys/kernel/hostname", "r")
  if f then
    host = f:read("*line")
  else
     local fhost = io.popen("hostname")
     host = fhost:read()
     fhost:close()
  end
  return host
end

return utilz
