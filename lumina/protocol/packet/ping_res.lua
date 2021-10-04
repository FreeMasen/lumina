local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

local PingRes = {}
PingRes.__index = PingRes
PingRes.__tostring = function(self)
    return require "lumina.utils".packet_string("PingRes", self)
end


function PingRes.new()
    return setmetatable({
        fixed_header = FixedHeader.from(PacketType.pingresp(), 0),
    }, PingRes)
end

function PingRes:encode_packet()
    return ""
end

function PingRes:encoded_packet_length()
    return 0
end

function PingRes:decode_packet(_, fixed_header)
    return PingRes.new(fixed_header)
end

return PingRes
