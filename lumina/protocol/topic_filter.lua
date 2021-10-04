local utils = require "lumina.utils"

---@class TopicFilter
---@field value string
local TopicFilter = {}
TopicFilter.__index = TopicFilter
TopicFilter.__tostring = function(self)
    return require "lumina.utils".packet_string("TopicFilter", self)
end

local function is_valid_topic_filter(s)
    if s == "" then
        return nil, "invalid topic filter, empty string"
    end
    if #s > 0xFFFF then
        return nil, "invalid topic filter, too long"
    end
    local last_ended_in_hash = false
    for part in string.gmatch(s, '[^/]+') do
        if last_ended_in_hash then
            return nil, string.format("invalid topic filter level after # %q", s)
        end
        local pre_hash, post_hash = string.match(part, "(.*)#(.*)")
        if (pre_hash and pre_hash ~= "") or (post_hash and post_hash ~= "") then
            return nil, string.format("invalid topic filter, chars around # %q", s)
        end
        last_ended_in_hash = part == "#"
        local pre_plus, post_plus = string.match(part, "(.*)%+(.*)")
        if (pre_plus and pre_plus ~= "") or (post_plus and post_plus ~= "") then
            return nil, string.format("invalid topic filter, chars around a + %q", s)
        end

    end
    return true
end

---
---@param value string
---@return TopicFilter
---@return string
function TopicFilter.new(value)
    local s, err = is_valid_topic_filter(value)
    if not s then
        return nil, err
    end

    return setmetatable({
        value = value,
    }, TopicFilter)
end

function TopicFilter.decode(source)
    local value, err = utils.decode_string(source)
    if not value then return nil, err end
    return TopicFilter.new(value)
end

function TopicFilter:encode()
    return utils.encode_string(self.value)
end

function TopicFilter:encoded_length()
    return 2 + #self.value
end

return TopicFilter
