local utils = require "lumina.utils"

--- @class PacketId
--- @field id integer
local PacketId = {}
PacketId.__index = PacketId
PacketId.__tostring = function(t)
    return require "lumina.utils".packet_string("PacketId", t)
end

function PacketId.from(value)
    return setmetatable({
        id = value,
    }, PacketId)
end

function PacketId.decode(source)
    assert(type(source) == "function", debug.traceback(type(source)))
    local value, err = utils.decode_u16(source)
    if not value then return nil, err end
    return PacketId.from(value)
end

function PacketId:encode()
    return utils.encode_u16(self.id)
end

function PacketId:encoded_length()
    return 2
end

return PacketId
