local TopicName = require "lumina.protocol.topic_name"
local utils = require "lumina.utils"

---@class TopicNameHeader
---@field value TopicName
local TopicNameHeader = {}
TopicNameHeader.__index = TopicNameHeader
TopicNameHeader.__tostring = function(t)
    return require "lumina.utils".packet_string("TopicNameHeader", t)
end

function TopicNameHeader.new(value)
    local tn, err = TopicName.from(value)
    if not tn then return nil, err end
    return TopicNameHeader.from(tn)
end

function TopicNameHeader.from(value)
    return setmetatable({
        value = value,
    }, TopicNameHeader)
end

function TopicNameHeader.decode(source)
    local value, err = utils.decode_string(source)
    if not value then return nil, err end
    return TopicNameHeader.new(value)
end

function TopicNameHeader:encode()
    return self.value:encode()
end

function TopicNameHeader:encoded_length()
    return self.value:encoded_length()
end

return TopicNameHeader
