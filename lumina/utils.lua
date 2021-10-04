local m = {}

function m.encode_u16(v)
    return string.pack(">H", v)
end

function m.decode_u16(source)
    assert(type(source) == "function", debug.traceback(type(source)))
    local bytes, err = assert(source(2))
    if not bytes then return nil, err end
    return string.unpack(">H", bytes)
end

function m.decode_string(source)
    local len, err = m.decode_u16(source)
    if not len then return nil, err end
    return source(len)
end

function m.encode_string(str)
    local len = #str
    if len > 65535 then
        return nil, "string too long"
    end
    return m.encode_u16(len) .. str
end

local function format_non_table(v)
    if v == nil then
        return 'nil'
    end
    if type(v) == 'string' then return string.format('\'%s\'', v) end
    return string.format('%s', v)
end

function m.table_string(v, pre, visited)
    pre = pre or ''
    visited = visited or {}
    if type(v) ~= 'table' then
        return format_non_table(v)
    elseif next(v) == nil then
        return '{ }'
    end
    local ret = '{'
    local orig_pre = pre
    pre = pre .. '  '
    visited[v] = true
    for key, value in pairs(v) do
        ret = ret .. '\n' .. pre .. key .. ' = '
        if type(value) == 'table' then
            if visited[value] then
                ret = ret .. '[recursive]'
            else
                ret = ret .. m.table_string(value, pre .. '  ', visited)
            end
        else
            ret = ret .. format_non_table(value)
        end
    end
    return string.format('%s\n%s}', ret, orig_pre)
end

function m.packet_string(name, packet)
    return name .. m.table_string(packet)
end

function m.sourceify(sock)
    return function(ct)
        return sock:receive(ct)
    end
end

return m
