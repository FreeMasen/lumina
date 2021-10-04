local utils = require "lumina.utils"

---@class KeepAlive
---@field interval integer
local KeepAlive = {}
KeepAlive.__index = KeepAlive
KeepAlive.__tostring = function(t)
    return require "lumina.utils".packet_string("KeepAlive", t)
end

function KeepAlive.from(value)
    return setmetatable({
        interval = value,
    }, KeepAlive)
end

function KeepAlive.decode(source)
    local value, err = utils.decode_u16(source)
    if not value then return nil, err end
    return KeepAlive.from(value)
end

function KeepAlive:encode()
    return utils.encode_u16(self.interval)
end

function KeepAlive:encoded_length()
    return 2
end

return KeepAlive
