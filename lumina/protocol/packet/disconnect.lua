local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

local Disconnect = {}
Disconnect.__index = Disconnect
Disconnect.__tostring = function(self)
    return require "lumina.utils".packet_string("Disconnect", self)
end


function Disconnect.new()
    return setmetatable({
        fixed_header = FixedHeader.from(PacketType.disconnect(), 0),
    }, Disconnect)
end

function Disconnect:encode_packet()
    return ""
end

function Disconnect:encoded_packet_length()
    return 0
end

function Disconnect:decode_packet(_, _fixed_header)
    return Disconnect.new()
end

return Disconnect
