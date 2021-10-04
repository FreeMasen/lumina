local PacketId = require "lumina.protocol.packet.variable_header.packet_id"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

local PubRel = {}
PubRel.__index = PubRel
PubRel.__tostring = function(self)
    return require "lumina.utils".packet_string("PubRel", self)
end


function PubRel.new(packet_id)
    return PubRel.from(
        PacketId.from(packet_id)
    )
end

function PubRel.from(packet_id)
    return setmetatable({
        fixed_header = FixedHeader.from(PacketType.pubrel(), 2),
        packet_id = packet_id,
    }, PubRel)
end

function PubRel:encode_packet()
    return self.packet_id:encode()
end

function PubRel:encoded_packet_length()
    return self.packet_id:encoded_length()
end

function PubRel.decode_packet(source)
    local id, err = PacketId.decode(source)
    if not id then return nil, err end
    return PubRel.from(id)
end

return PubRel
