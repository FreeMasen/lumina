local PacketType = require "lumina.protocol.packet.packet_type"

---@class FixedHeader
---@field packet_type PacketType
---@field remaining_length integer
local FixedHeader = {}
FixedHeader.__index = FixedHeader
FixedHeader.__tostring = function(t)
    return require "lumina.utils".packet_string("FixedHeader", t)
end

---
---@param packet_type integer
---@param remaining_length integer
---@return FixedHeader
function FixedHeader.new(packet_type, remaining_length)
    assert(type(packet_type) == "number", debug.traceback(type(packet_type)))
    local packet_type, err = PacketType.new(packet_type)
    if not packet_type then
        return nil, err
    end
    if type(remaining_length) ~= "number" then
        return nil, "remaining_length must be a number"
    end
    return FixedHeader.from(packet_type, remaining_length)
end

---
---@param packet_type PacketType
---@param remaining_length integer
---@return FixedHeader
function FixedHeader.from(packet_type, remaining_length)
    return setmetatable({
        packet_type = packet_type,
        remaining_length = remaining_length,
    }, FixedHeader)
end

function FixedHeader.decode(source)
    local packet_type, remaining_length
    local s, err = pcall(function()
        packet_type = assert(PacketType.decode(source))
        remaining_length = 0
        for i=0,5 do
            if i > 4 then
                error("invalid remaining length encoding, 4th byte had continue big set")
            end
            local byte = string.byte(assert(source(1)))
            local masked = byte & 0x7F
            local shifted = masked << (7 * i)
            remaining_length = remaining_length | shifted
            if byte & 0x80 == 0 then
                break
            end
        end
    end)
    if not s then
        return nil, err
    end
    return FixedHeader.from(packet_type, remaining_length)
end

function FixedHeader:encode()
    local ret = self.packet_type:encode()
    local current_length = self.remaining_length
    while true do
        local byte = current_length & 0x7F
        current_length = current_length >> 7
        if current_length > 0 then
            byte = byte | 0x80
        end
        ret = ret .. string.char(byte)
        if current_length == 0 then
            break
        end
    end
    return ret
end

function FixedHeader:encoded_length()
    local len_len = 1
    if self.remaining_length >= 2097152 then
        len_len = 4
    elseif self.remaining_length >= 16384 then
        len_len = 3
    elseif self.remaining_length >= 128 then
        len_len = 2
    end
    return 1 + len_len
end

return FixedHeader
