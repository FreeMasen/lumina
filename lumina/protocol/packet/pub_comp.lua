local PacketId = require "lumina.protocol.packet.variable_header.packet_id"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"
local PubComp = {}
PubComp.__index = PubComp
PubComp.__tostring = function(self)
    return require "lumina.utils".packet_string("PubComp", self)
end

function PubComp.new(packet_id)
    return PubComp.from(PacketId.from(packet_id))
end

function PubComp.from(packet_id)
    return setmetatable({
        fixed_header = FixedHeader.from(PacketType.pubcomp(), 2),
        packet_id = packet_id,
    }, PubComp)
end

function PubComp:encode_packet()
    return self.packet_id:encode()
end

function PubComp:encoded_packet_length()
    return self.packet_id:encoded_length()
end

function PubComp.decode_packet(source)
    local id, err = PacketId.decode(source)
    if not id then return nil, err end
    return PubComp.from(id)
end

return PubComp
