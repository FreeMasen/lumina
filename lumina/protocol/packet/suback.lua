local PacketId = require "lumina.protocol.packet.variable_header.packet_id"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"
---@class SubAck
---@field fixed_header FixedHeader
---@field packet_id PacketId
---@field payload SubAckPayload
local SubAck = {}
SubAck.__index = SubAck
SubAck.__tostring = function(self)
    return require "lumina.utils".packet_string("SubAck", self)
end

---@class SubAckPayload
---@field subscribes SubReturnCode[]
local SubAckPayload = {}
SubAckPayload.__index = SubAckPayload
SubAckPayload.__tostring = function(self)
    local subs = {}
    for _, sub in pairs(self.subscribes) do
        table.insert(subs, tostring(sub))
    end
    return string.format(
        "SubAckPayload { subscribes = [%s] }",
        table.concat(subs, ", ")
    )
end

---@class SubReturnCode
---@field value integer
local SubReturnCode = {
    MaximumQoSLevel0 = 0x00,
    MaximumQoSLevel1 = 0x01,
    MaximumQoSLevel2 = 0x02,
    Failure = 0x80,
}
SubReturnCode.__index = SubReturnCode
SubReturnCode.__tostring = function(self)
    local s = "UNKNOWN("..tostring(self.value)..")"
    if self.value == 0x00 then
        s = "MaximumQoSLevel0"
    elseif self.value == 0x01 then
        s = "MaximumQoSLevel1"
    elseif self.value == 0x02 then
        s = "MaximumQoSLevel2"
    elseif self.value == 0x80 then
        s = "Failure"
    end
    return string.format(
        "SubReturnCode::%s",
        s
    )
end

function SubAck.new(packet_id, subscribes)
    local payload, err = SubAckPayload.new(subscribes)
    if not payload then return nil, err end
    return SubAck.from(
        PacketId.from(packet_id),
        payload
    )
end

function SubAck.from(packet_id, payload)
    local ret = setmetatable({
        fixed_header = FixedHeader.from(PacketType.suback(), 0),
        packet_id = packet_id,
        payload = payload,
    }, SubAck)
    ret:reset_reminaing_length()
    return ret
end

function SubAck:encode_packet()
    return self.packet_id:encode() .. self.payload:encode()
end

function SubAck:encoded_packet_length()
    return self.packet_id:encoded_length() + self.payload:encoded_length()
end

function SubAck.decode_packet(source, fixed_header)
    local id, payload
    id = assert(PacketId.decode(source))
    payload = assert(SubAckPayload.decode(source, fixed_header.remaining_length - 2))
    local s, err = pcall(function()
    end)
    if not s then return nil, err end
    return SubAck.from(id, payload)
end

function SubAck:reset_reminaing_length()
    self.fixed_header.remaining_length = self:encoded_packet_length()
end

function SubAckPayload.new(subscribes)
    local codes = {}
    local s, err = pcall(function()
        for _, sub in pairs(subscribes) do
            table.insert(codes, assert(SubReturnCode.from(sub)))
        end
    end)
    if not s then return nil, err end
    return SubAckPayload.from(codes)
end

function SubAckPayload.from(subscribes)
    return setmetatable({
        subscribes = subscribes,
    }, SubAckPayload)
end

function SubAckPayload:encode()
    local ret = ""
    for _, subscribe in pairs(self.subscribes) do
        ret = ret .. subscribe:encode()
    end
    return ret
end

function SubAckPayload:encoded_length()
    return #self.subscribes
end

function SubAckPayload.decode(source, payload_len)
    local subs = {};
    for i=1,payload_len do
        local sub_ret_code = assert(SubReturnCode.decode(source))
        table.insert(subs, sub_ret_code)
    end
    return SubAckPayload.from(subs)
end

function SubReturnCode.from(value)
    assert(value, debug.traceback())
    if not value or value < 0 or value > 2 and value ~= 0x80 then
        return nil, string.format("Invalid subscribe return code expected 0, 1, 2 or 8 found %s", value)
    end
    return setmetatable({
        value = value,
    }, SubReturnCode)
end

function SubReturnCode.decode(source)
    local value, err = assert(source(1))
    if not value then return nil, err end
    value = string.byte(value)
    return SubReturnCode.from(value)
end

function SubReturnCode:encode()
    return string.char(self.value)
end

return SubAck
