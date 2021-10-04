local utils = require "lumina.utils"
---@class ProtocolName
---@field value string
local ProtocolName = {}
ProtocolName.__index = ProtocolName
ProtocolName.__tostring = function(t)
    return require "lumina.utils".packet_string("ProtocolName", t)
end

function ProtocolName.from(value)
    return setmetatable({
        value = value,
    }, ProtocolName)
end

function ProtocolName.decode(source)
    local value, err = utils.decode_string(source)
    if not value then return nil, err end
    return ProtocolName.from(value)
end

function ProtocolName:encode()
    return utils.encode_string(self.value)
end

function ProtocolName:encoded_length()
    return 2 + #self.value
end

return ProtocolName
