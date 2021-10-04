local utils = require "lumina.utils"

---@class TopicName
---@field value string
local TopicName = {}
TopicName.__index = TopicName
TopicName.__tostring = function(self)
    return require "lumina.utils".packet_string("TopicName", self)
end

function TopicName.from(value)
    if not string.match(value, "^[^#+]+$") then
        return nil, string.format("Invalid topic name %q", value)
    end
    return setmetatable({
        value = value,
    }, TopicName)
end

function TopicName.decode(source)
    local value, err = utils.decode_string(source)
    if not value then return nil, err end
    return TopicName.from(value)
end

function TopicName:encode()
    return utils.encode_string(self.value)
end

function TopicName:encoded_length()
    return 2 + #self.value
end

return TopicName
