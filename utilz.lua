local utilz = { string = {} }

function utilz.string.gsplit(s, sep, plain)
    local start = 1
    local done = false
    local function pass(i, j, ...)
        if i then
            local seg = s:sub(start, i - 1)
            start = j + 1
            return seg, ...
        else
            done = true
            return s:sub(start)
        end
    end
    return function()
        if done then return end
        if sep == '' then done = true return s end
        return pass(s:find(sep, start, plain))
    end
end

function utilz.lineswrap(s, n)
    local lines = {}
    for line in utilz.string.gsplit(s, "\n") do lines[#lines+1] = line end
    while #lines > n do table.remove(lines, 1) end
    if #lines == 0 then return "\n" end
    return table.concat(lines, "\n")
end

return utilz
