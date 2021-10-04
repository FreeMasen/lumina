local TopicNameHeader = require "lumina.protocol.packet.variable_header.topic_name"
local PacketId = require "lumina.protocol.packet.variable_header.packet_id"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"

local utils = require "lumina.utils"
---@class Publish
---@field fixed_header FixedHeader
---@field topic_name TopicNameHeader
---@field packet_id PacketId|nil
---@field qos integer
---@field payload string
local Publish = {}
Publish.__index = Publish
Publish.__tostring = function(self)
    return require "lumina.utils".packet_string("Publish", self)
end


function Publish.new(topic_name, packet_id, qos, payload, fixed_header)
    if qos == 0 and packet_id ~= nil then
        return nil, "publish with a level 0 quality of service cannot have a packet id"
    end
    local tn = assert(TopicNameHeader.new(topic_name));
    return Publish.from(
        tn,
        packet_id and PacketId.from(packet_id),
        qos,
        payload,
        fixed_header
    )
end

function Publish.from(topic_name, packet_id, qos, payload, fixed_header)
    local fixed_header = fixed_header or assert(FixedHeader.from(PacketType.from(3, qos << 1), 0))
    local ret = setmetatable({
        fixed_header = fixed_header,
        topic_name = topic_name,
        packet_id = packet_id,
        payload = payload,
    }, Publish)
    ret:reset_reminaing_length()
    return ret
end

function Publish:encode_packet()
    local topic, id
    self:reset_reminaing_length()
    local s, err = pcall(function()
        topic = assert(self.topic_name:encode())
        if self.packet_id then
            id = assert(self.packet_id:encode())
        else
            id = ""
        end
    end)
    if not s then return nil, err end
    return topic .. id .. self.payload
end

function Publish:reset_reminaing_length()
    self.fixed_header.remaining_length = self:encoded_packet_length()
end

function Publish:encoded_packet_length()
    assert(self.topic_name, require("lumina.utils").table_string(self)..debug.traceback())
    local ret = self.topic_name:encoded_length()
    if self.packet_id then
        ret = ret + self.packet_id:encoded_length()
    end
    return ret + #self.payload
end

---comment
---@param source fun(i:integer):string
---@param fixed_header FixedHeader
---@return any
---@return any
function Publish.decode_packet(source, fixed_header)
    local topic, qos, id, payload
    local s, err = pcall(function()
        topic = assert(TopicNameHeader.decode(source))
        qos = (fixed_header.packet_type._flags & 6) >> 1;
        local len_diff = 0
        if qos > 0 then
            id = assert(PacketId.decode(source))
            len_diff = 2
        end
        payload = source(fixed_header.remaining_length - len_diff)
    end)
    if not s then return nil, err end
    return Publish.from(topic, id, qos, payload, fixed_header)
end

return Publish
