local PacketId = require "lumina.protocol.packet.variable_header.packet_id"
local FixedHader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

---@class UnsubAck
---@field fixed_header FixedHeader
---@field packet_id PacketId
local UnsubAck = {}
UnsubAck.__index = UnsubAck
UnsubAck.__tostring = function(self)
    return require "lumina.utils".packet_string("UnsubAck", self)
end

function UnsubAck.new(packet_id)
    return UnsubAck.from(PacketId.from(packet_id))
end

function UnsubAck.from(packet_id)
    return setmetatable({
        fixed_header = FixedHader.from(PacketType.unsuback(), 2),
        packet_id = packet_id,
    }, UnsubAck)
end

function UnsubAck:encode_packet()
    return self.packet_id:encode()
end

function UnsubAck:encoded_packet_length()
    return self.packet_id:encoded_length()
end

function UnsubAck.decode_packet(source)
    local id, err = PacketId.decode(source)
    if not id then return nil, err end
    return UnsubAck.from(id)
end

return UnsubAck
