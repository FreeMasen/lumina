local PacketId = require "lumina.protocol.packet.variable_header.packet_id"
local TopicFilter = require "lumina.protocol.topic_filter"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

---@class Subscribe
---@field fixed_header FixedHeader
---@field packet_id PacketId
---@field payload SubscribePayload
local Subscribe = {}
Subscribe.__index = Subscribe
Subscribe.__tostring = function(self)
    return require "lumina.utils".packet_string("Subscribe", self)
end

---@class SubscribePayload
---@field subscribes Subscription[]
local SubscribePayload = {}
SubscribePayload.__index = SubscribePayload

SubscribePayload.__tostring = function(self)
    local subs = {}
    for _, sub in pairs(self.subscribes) do
        table.insert(subs, tostring(sub))
    end
    return string.format(
        "SubscribePayload { subscribes = [%s] }",
        table.concat(subs, ", ")
    )
end

---@class Subscription
---@field filter TopicFilter
---@field qos integer
local Subscription = {}
Subscription.__index = Subscription
Subscription.__tostring = function(self)
    return string.format(
        "Subscription { filter = %s, qos = %s }",
        self.filter,
        self.qos
    )
end

function Subscribe.new(packet_id, subscribes)
    local subs, err = SubscribePayload.new(subscribes)
    if not subs then return nil, err end
    return Subscribe.from(
        PacketId.from(packet_id),
        subs
    )
end

function Subscribe.from(packet_id, payload)
    local ret = setmetatable({
        fixed_header = FixedHeader.from(PacketType.subscribe(), 0),
        packet_id = packet_id,
        payload = payload,
    }, Subscribe)
    ret:reset_remaining_length()
    return ret
end

function Subscribe:encode_packet()
    local pid, payload
    local s, err = pcall(function()
        pid = assert(self.packet_id:encode())
        payload = assert(self.payload:encode())
    end)
    if not s then return nil, err end
    return pid .. payload
end

function Subscribe:encoded_packet_length()
    return self.packet_id:encoded_length() + self.payload:encoded_length()
end

function Subscribe:reset_remaining_length()
    self.fixed_header.remaining_length = self:encoded_packet_length()
end

function Subscribe.decode_packet(source, fixed_header)
    local id, payload
    local s, err = pcall(function()
        id = assert(PacketId.decode(source))
        payload = assert(SubscribePayload.decode_with(source, fixed_header.remaining_length - 2))
    end)
    if not s then return nil, err end
    return Subscribe.from(id, payload)
end


function SubscribePayload.new(subscribes)
    local subs = {}
    for i, sub in ipairs(subscribes) do
        if type(sub) == "string" then
            local s, err = Subscription.new(sub, 0)
            if not s then
                return nil, err
            end
            table.insert(subs, s)
        elseif type(sub) == "table" then
            if not sub.filter then
                return nil, string.format("Index %s of subscribes did not have a filter property", i)
            end
            local s, err = Subscription.new(sub.filter, sub.qos or 0)
            if not s then
                return nil, err
            end
            table.insert(subs, s)
        else
            return nil, string.format("Index %s of subscribes was not a string or table", i)
        end
    end
    return SubscribePayload.from(subs)
end

function SubscribePayload.from(subscribes)
    return setmetatable({
        subscribes = subscribes,
    }, SubscribePayload)
end

function SubscribePayload:encode()
    local ret = ""
    for _, subscribe in pairs(self.subscribes) do
        ret = ret .. subscribe:encode()
    end
    return ret
end

function SubscribePayload.decode_with(source, len)
    local subs = {}
    local s, err = pcall(function()
        while len > 0 do
            local sub = assert(Subscription.decode(source))
            table.insert(subs, sub)
            len = len - sub:encoded_length()
        end
    end)
    if not s then return nil, err end
    return SubscribePayload.from(subs)
end

function SubscribePayload:encoded_length()
    local ret = 0
    for _, sub in ipairs(self.subscribes) do
       ret = ret + sub:encoded_length()
    end
    return ret
end

function Subscription.new(filter, qos)
    local f, err = TopicFilter.new(filter)
    if not f then return nil, err end
    return setmetatable({
        filter = f,
        qos = qos,
    }, Subscription)
end

function Subscription.from(filter, qos)
    return setmetatable({
        filter = filter,
        qos = qos,
    }, Subscription)
end

function Subscription.decode(source)
    local filter, qos
    local s, err = pcall(function()
        filter = assert(TopicFilter.decode(source))
        qos = assert(source(1))
        qos = string.byte(qos)
    end)
    if not s then return nil, err end
    return Subscription.from(filter, qos)
end

function Subscription:encode()
    local filter = self.filter:encode()
    local qos = string.char(self.qos)
    return filter .. qos
end

function Subscription:encoded_length()
    return 1 + self.filter:encoded_length()
end

return Subscribe
