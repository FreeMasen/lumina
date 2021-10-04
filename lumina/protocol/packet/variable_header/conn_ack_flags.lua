
---@class ConnAckFlags
---@field session_present boolean
local ConnAckFlags = {}
ConnAckFlags.__index = ConnAckFlags
ConnAckFlags.__tostring = function(t)
    return require "lumina.utils".packet_string("ConnAckFlags", t)
end
ConnAckFlags.__eq = function(self, other)
    return self.session_present == other.session_present
end

function ConnAckFlags.new(session_present)
    return setmetatable({
        session_present = session_present
    }, ConnAckFlags)
end

function ConnAckFlags.decode(source)
    local byte, err = source(1)
    if not byte then
        return nil, err
    end
    byte = string.byte(byte)
    if byte == 0 then return ConnAckFlags.new(false) end
    if byte == 1 then return ConnAckFlags.new(true) end
    return nil, string.format("Expected 0 or 1 found %s", byte)
end

function ConnAckFlags:encode()
    if self.session_present then
        return string.char(1)
    else
        return string.char(0)
    end
end

function ConnAckFlags:encoded_length()
    return 1
end

return ConnAckFlags
