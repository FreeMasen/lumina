
local packet_names = {
    [1] = "Connect",
    [2] = "ConnAck",
    [3] = "Publish",
    [4] = "PubAck",
    [5] = "PubRec",
    [6] = "PubRel",
    [7] = "PubComp",
    [8] = "Subscribe",
    [9] = "SubAck",
    [10] = "Unsubscribe",
    [11] = "UnsubAck",
    [12] = "PingReq",
    [13] = "PingRes",
    [14] = "Disconnect",
}
packet_names.__index = function() return "Unknown" end

---@class PacketType
---@field _control_type integer
---@field _flags integer
local PacketType = {}
PacketType.__index = PacketType
PacketType.__tostring = function(t)
    return require "lumina.utils".packet_string("PacketType", t)
end

function PacketType.new(n)
    if type(n) ~= "number" then
        return nil, "bad argument to PacketType.new, expected number found " .. type(n)
    end
    local control_type = n >> 4
    local flags = n & 0x0F
    return PacketType.from(control_type, flags)
end

function PacketType.from(value, flags)
    if type(value) ~= "number" then
        return nil, string.format("Invalid packet type expected number found %q", type(value))
    end
    if value < 1 or value > 14 then
        return nil, string.format("Invalid packet type, expected value between 1 and 14 found %s", value)
    end
    flags = flags or PacketType.default_flags(value)
    if type(flags) ~= "number" then
        return nil, string.format("Invalid packet type flags expected number found %q", type(value))
    end
    if flags > 15 then
        return nil, string.format("Invalid packet type flags, expected value between 0 and 15 found %s", value)
    end
    if value == 3 then
        local qos = (flags & 6) >> 1
        if qos > 2 or qos < 0 then
            return nil, string.format("Invalid packet type flags for %s: %s", packet_names[value], flags)
        end
    elseif flags ~= PacketType.default_flags(value) then
        return nil, string.format("Invalid packet type flags for %s: %s", packet_names[value], flags)
    end

    return setmetatable({
        _control_type = value,
        _flags = flags,
    }, PacketType)
end

function PacketType.default_flags(control_type)
    if control_type == 6
    or control_type == 8
    or control_type == 10
    then
        return 2
    end
    return 0
end


function PacketType:encode()
    return string.char(((self._control_type & 0x0F) << 4) | (self._flags & 0x0F))
end

function PacketType.decode(source)
    local byte = assert(source(1))
    byte = string.byte(byte)
    return PacketType.new(byte)
end

function PacketType.connect()
    return PacketType.from(1, PacketType.default_flags(1))
end
function PacketType.connack()
    return PacketType.from(2, PacketType.default_flags(2))
end
function PacketType.publish()
    return PacketType.from(3, PacketType.default_flags(3))
end
function PacketType.puback()
    return PacketType.from(4, PacketType.default_flags(4))
end
function PacketType.pubrec()
    return PacketType.from(5, 0)
end
function PacketType.pubrel()
    return PacketType.from(6, 2)
end
function PacketType.pubcomp()
    return PacketType.from(7, PacketType.default_flags(7))
end
function PacketType.subscribe()
    return PacketType.from(8, 2)
end
function PacketType.suback()
    return PacketType.from(9, PacketType.default_flags(9))
end
function PacketType.unsubscribe()
    return PacketType.from(10, 2)
end
function PacketType.unsuback()
    return PacketType.from(11, PacketType.default_flags(11))
end
function PacketType.pingreq()
    return PacketType.from(12, PacketType.default_flags(21))
end
function PacketType.pingresp()
    return PacketType.from(13, PacketType.default_flags(31))
end
function PacketType.disconnect()
    return PacketType.from(14, PacketType.default_flags(41))
end

return PacketType