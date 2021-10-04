local utils = require "lumina.utils"

---@class ProtocolLevel
---@field value integer
local ProtocolLevel = {
    SPEC_3_1_0 = 0x03,
    SPEC_3_1_1 = 0x04,
    SPEC_5_0 = 0x5,
}
ProtocolLevel.__index = ProtocolLevel
ProtocolLevel.__tostring = function(t)
    return require "lumina.utils".packet_string("ProtocolLevel", t)
end

function ProtocolLevel.from(value)
    if value < 0x03 or value > 0x05 then
        return nil, string.format("expected value between 3 and 5 found %s", value)
    end
    return setmetatable({
        value = value,
    }, ProtocolLevel)
end

function ProtocolLevel.decode(source)
    local value, err = source(1)
    if not value then return nil, err end
    return ProtocolLevel.from(string.byte(value))
end

function ProtocolLevel:encode()
    return string.char(self.value)
end

function ProtocolLevel:encoded_length()
    return 1
end

return ProtocolLevel
