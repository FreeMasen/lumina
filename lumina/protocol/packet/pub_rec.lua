local PacketId = require "lumina.protocol.packet.variable_header.packet_id"

local PubRec = {}
PubRec.__index = PubRec
PubRec.__tostring = function(self)
    return require "lumina.utils".packet_string("PubRec", self)
end

function PubRec.new(fixed_header, packet_id)
    return setmetatable({
        fixed_header = fixed_header,
        packet_id = packet_id,
    }, PubRec)
end

function PubRec:encode_packet()
    return self.packet_id:encode()
end

function PubRec:encoded_packet_length()
    return self.packet_id:encoded_length()
end

function PubRec.decode_packet(source, fixed_header)
    local id, err = PacketId.decode(source)
    if not id then return nil, err end
    return PubRec.new(fixed_header, id)
end

return PubRec
