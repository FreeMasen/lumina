local PacketId = require "lumina.protocol.packet.variable_header.packet_id"
local TopicFilter = require "lumina.protocol.topic_filter"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

---@class Unsubscribe
---@field fixed_header FixedHeader
---@field packet_id PacketId
---@field payload UnsubscribePayload
local Unsubscribe = {}
Unsubscribe.__index = Unsubscribe
Unsubscribe.__tostring = function(self)
    return require "lumina.utils".packet_string("Unsubscribe", self)
end

---@class UnsubscribePayload
---@field topic_filters TopicFilter[]
local UnsubscribePayload = {}
UnsubscribePayload.__index = UnsubscribePayload
UnsubscribePayload.__tostring = function(self)
    return require "lumina.utils".packet_string("UnsubscribePayload", self)
end

---
---@param packet_id integer
---@param payload string[]
---@return Unsubscribe
function Unsubscribe.new(packet_id, payload)
    return Unsubscribe.from(
        PacketId.from(packet_id),
        UnsubscribePayload.new(payload)
    )
end

---
---@param packet_id PacketId
---@param payload UnsubscribePayload
---@return Unsubscribe
function Unsubscribe.from(packet_id, payload)
    local ret = setmetatable({
        fixed_header = FixedHeader.from(PacketType.unsubscribe(), 0),
        packet_id = packet_id,
        payload = payload,
    }, Unsubscribe)
    ret:reset_reminaing_length()
    return ret
end

---
---@return string
---@return string
function Unsubscribe:encode_packet()
    local pid, payload
    local s, err = pcall(function()
        pid = assert(self.packet_id:encode())
        payload = assert(self.payload:encode())
    end)
    if not s then return nil, err end
    return pid .. payload
end

---set the fixed_header's remaining length property
function Unsubscribe:reset_reminaing_length()
    self.fixed_header.remaining_length = self:encoded_packet_length()
end

---Return the length of the non-fixed header portion of this packet
---@return integer
function Unsubscribe:encoded_packet_length()
    return self.packet_id:encoded_length() + self.payload:encoded_length()
end

---
---@param source fun(len:integer):string
---@param fixed_header FixedHeader
---@return Unsubscribe
---@return string
function Unsubscribe.decode_packet(source, fixed_header)
    local id, payload
    local s, err = pcall(function()
        id = assert(PacketId.decode(source))
        payload = assert(UnsubscribePayload.decode_with(source, fixed_header.remaining_length - id:encoded_length()))
    end)
    if not s then return nil, err end
    return Unsubscribe.from(id, payload)
end

---
---@param topic_filters string[]
---@return UnsubscribePayload
---@return any
function UnsubscribePayload.new(topic_filters)
    local tops = {}
    local s, err = pcall(function()
        for _, filter in ipairs(topic_filters) do
            table.insert(tops, assert(TopicFilter.new(filter)))
        end
    end)
    if not s then return nil, err end
    return UnsubscribePayload.from(tops)
end

---
---@param topic_filters TopicFilter[]
---@return UnsubscribePayload
function UnsubscribePayload.from(topic_filters)
    return setmetatable({
        topic_filters = topic_filters,
    }, UnsubscribePayload)
end

---
---@return string
function UnsubscribePayload:encode()
    local ret = ""
    for _, topic_filter in pairs(self.topic_filters) do
        ret = ret .. topic_filter:encode()
    end
    return ret
end

---
---@return integer
function UnsubscribePayload:encoded_length()
    local ret = 0
    for _, tf in pairs(self.topic_filters) do
        ret = ret + tf:encoded_length()
    end
    return ret
end

---comment
---@param source fun(len:integer):string
---@param len integer total bytes of payload
---@return UnsubscribePayload
---@return string
---@return TopicFilter[]
function UnsubscribePayload.decode_with(source, len)
    local topic_filters = {}
    local s, err = pcall(function()
        while len > 0 do
            local part = assert(TopicFilter.decode(source))
            table.insert(topic_filters, part)
            len = len - part:encoded_length()
        end
    end)
    if not s then return nil, err, topic_filters end
    return UnsubscribePayload.from(topic_filters)
end

return Unsubscribe
