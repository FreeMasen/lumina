local ConnAckFlags = require "lumina.protocol.packet.variable_header.conn_ack_flags"
local ConnAckRetCode = require "lumina.protocol.packet.variable_header.connect_ret_code"
local FixedHeader = require "lumina.protocol.packet.fixed_header"

---@class ConnAckPacket
---@field fixed_header FixedHeader
---@field flags ConnAckFlags
---@field ret_code ConnReturnCode
local ConnAckPacket = {}
ConnAckPacket.__index = ConnAckPacket
ConnAckPacket.__tostring = function(self)
    return require "lumina.utils".packet_string("ConnAckPacket", self)
end

---
---@param session_present boolean
---@param ret_code integer
---@return ConnAckPacket
function ConnAckPacket.new(session_present, ret_code)
    return ConnAckPacket.from(
        FixedHeader.new(2, 0),
        ConnAckFlags.new(session_present or false),
        ConnAckRetCode.from(ret_code)
    )
end

function ConnAckPacket.from(fixed_header, flags, ret_code)
    local ret = setmetatable({
        fixed_header = fixed_header,
        flags = flags,
        ret_code = ret_code,
    }, ConnAckPacket)
    ret:reset_remaining_length()
    return ret
end

function ConnAckPacket:encode_packet()
    return self.flags:encode() .. self.ret_code:encode()
end

function ConnAckPacket:encoded_packet_length()
    return self.flags:encoded_length()
        + self.ret_code:encoded_length()
end

function ConnAckPacket.decode_packet(source, fixed_header)
    local flags, code, err
    flags, err = ConnAckFlags.decode(source)
    if not flags then return nil, err end
    code = ConnAckRetCode.decode(source)
    return ConnAckPacket.from(fixed_header, flags, code)
end

function ConnAckPacket:reset_remaining_length()
    self.fixed_header.remaining_length = self:encoded_packet_length()
end

return ConnAckPacket
