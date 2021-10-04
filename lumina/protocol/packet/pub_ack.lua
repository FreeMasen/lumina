local PacketId = require "lumina.protocol.packet.variable_header.packet_id"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

---@class PubAck
---@field fixed_header FixedHeader
---@field packet_id PacketId
local PubAck = {}
PubAck.__index = PubAck
PubAck.__tostring = function(self)
    return require "lumina.utils".packet_string("PubAck", self)
end

---
---@param packet_id string
---@return PubAck
function PubAck.new(packet_id)
    return PubAck.from(PacketId.from(packet_id))
end

---
---@param packet_id PacketId
---@return PubAck
function PubAck.from(packet_id)
    return setmetatable({
        fixed_header = FixedHeader.from(PacketType.puback(), 2),
        packet_id = packet_id,
    }, PubAck)
end

function PubAck:encode_packet()
    return self.packet_id:encode()
end

function PubAck:encoded_packet_length()
    return self.packet_id:encoded_length()
end

function PubAck.decode_packet(source)
    local id, err = PacketId.decode(source)
    if not id then return nil, err end
    return PubAck.from(id)
end

return PubAck
