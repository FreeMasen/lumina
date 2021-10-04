local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

local PingReq = {}
PingReq.__index = PingReq
PingReq.__tostring = function(self)
    return require "lumina.utils".packet_string("PingReq", self)
end


function PingReq.new()
    return setmetatable({
        fixed_header = FixedHeader.from(PacketType.pingreq(), 0),
    }, PingReq)
end

function PingReq:encode_packet()
    return ""
end

function PingReq:encoded_packet_length()
    return 0
end

function PingReq:decode_packet(_, fixed_header)
    return PingReq.new(fixed_header)
end

return PingReq
