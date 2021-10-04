local m = {}

function m.generate_source(str)
    local idx = 1
    local len = #str
    return function(n)
        local ret = str:sub(idx, idx+n - 1)
        idx = idx + n
        if not ret or #ret == 0 then return ret, 'eof' end
        return ret
    end
end

function m.debug_bytes(s)
    local bytes = table.pack(string.byte(s, 1, #s))
    local t = {}
    for _, byte in ipairs(bytes) do
        table.insert(t, tostring(byte))
    end
    return table.concat(t, '|')
end

function m.bytes_match(expected, test)
    if expected == test then
        return 1
    end
    local expected = m.debug_bytes(expected)
    local test = m.debug_bytes(test)
    return nil, table.concat({
        '1. ' .. expected,
        '2. ' .. test
    }, '\n')
end
return m
