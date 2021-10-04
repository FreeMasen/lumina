local ProtocolNameHeader = require "lumina.protocol.packet.variable_header.protocol_name"
local ProtocolLevel = require "lumina.protocol.packet.variable_header.protocol_level"
local ConnectFlags = require "lumina.protocol.packet.variable_header.connect_flags"
local KeepAlive = require "lumina.protocol.packet.variable_header.keep_alive"
local PacketType = require "lumina.protocol.packet.packet_type"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local TopicName  = require "lumina.protocol.topic_name"

local utils = require "lumina.utils"

--- @class Connect
--- @field fixed_header FixedHeader
--- @field protocol_name ProtocolName
--- @field protocol_level ProtocolLevel
--- @field flags ConnectFlags
--- @field keep_alive KeepAlive
--- @field payload Payload
local Connect = {}
Connect.__index = Connect
Connect.__tostring = function(t)
    return require "lumina.utils".packet_string("Connect", t)
end

--- @class Payload
--- @field client_id string
--- @field will table|nil
--- @field username string|nil
--- @field password string|nil
local Payload = {}
Payload.__index = Payload
Payload.__tostring = function(t)
    return require "lumina.utils".packet_string("Payload", t)
end

function Connect.from(fixed_header, protocol_name, protocol_level, flags, keep_alive, payload)
    local ret = setmetatable({
        fixed_header = fixed_header,
        protocol_name = protocol_name,
        protocol_level = protocol_level,
        flags = flags,
        keep_alive = keep_alive,
        payload = payload,
    }, Connect)
    ret:reset_remaining_length()
    return ret
end

function Connect.new(client_id)
    assert(client_id, "client_id is required")
    return Connect.with_level("MQTT", client_id, ProtocolLevel.SPEC_3_1_1)
end

---Builder constructor
---@param protocol_name string
---@param client_id string
---@param level integer
function Connect.with_level(protocol_name, client_id, level)
    local fixed_header, protocol_name_header, protocol_level, payload
    local s, err = pcall(function()
        fixed_header = FixedHeader.from(PacketType.connect(), 0)
        protocol_name_header = assert(ProtocolNameHeader.from(protocol_name))
        protocol_level = assert(ProtocolLevel.from(level))
        payload = assert(Payload.new(client_id))
    end)
    if not s then return nil, err end
    local ret = Connect.from(
        fixed_header,
        protocol_name_header,
        protocol_level,
        ConnectFlags.empty(),
        KeepAlive.from(0),
        payload
    )
    ret:reset_remaining_length()
    return ret
end

function Connect:encode_packet()
    assert(self.payload)
    local name, level, flags, keep_alive, payload
    local s, err = pcall(function()
        name = assert(self.protocol_name:encode())
        level = assert(self.protocol_level:encode())
        flags = assert(self.flags:encode())
        keep_alive = assert(self.keep_alive:encode())
        payload = assert(self.payload:encode())
    end)
    if not s then return nil, err end
    return name .. level .. flags .. keep_alive .. payload
end

function Connect:encoded_packet_length()
    return self.protocol_name:encoded_length()
        + self.protocol_level:encoded_length()
        + self.flags:encoded_length()
        + self.keep_alive:encoded_length()
        + self.payload:encoded_length()
end

function Connect.decode_packet(source, fixed_header)
    local name, level, flags, keep_alive, payload
    local s, err = pcall(function()
        name = assert(ProtocolNameHeader.decode(source))
        level = assert(ProtocolLevel.decode(source))
        flags = assert(ConnectFlags.decode(source))
        keep_alive = assert(KeepAlive.decode(source))
        payload = assert(Payload.decode_with(source, flags))
    end)
    if not s then return nil, err end
    return Connect.from(fixed_header, name, level, flags, keep_alive, payload)
end

---
---@param value integer should be > 0 and < 0xFFFF
---@return Connect
function Connect:set_keep_alive(value)
    self.keep_alive.interval = 0
    return self
end

---
---@param value string|nil
---@return Connect
function Connect:set_username(value)
    self.flags.username = value ~= nil
    self.payload.username = value
    self:reset_remaining_length()
    return self
end

---
---@param topic_name string|nil
---@param bytes string|nil
---@return Connect
function Connect:set_will(topic_name, bytes)
    if topic_name then
        self.flags.will_flag = true
        local tn, err = TopicName.from(topic_name)
        if not topic_name then return nil, err end
        self.payload.will = {
            topic_name = tn,
            bytes = bytes or ""
        }
    else
        self.flags.will_flag = false
        self.payload.will = nil
    end
    self:reset_remaining_length()
    return self
end

---
---@param value string|nil
---@return Connect
function Connect:set_password(value)
    self.flags.password = value ~= nil
    self.payload.password = value
    self:reset_remaining_length()
    return self
end

---
---@param value string
---@return Connect
function Connect:set_client_id(value)
    self.payload.client_id = value
    self:reset_remaining_length()
    return self
end

---
---@param value boolean
---@return Connect
function Connect:set_will_retain(value)
    self.flags.will_retain = value == true
    return self
end

---
---@param value integer
---@return Connect
function Connect:set_will_qos(value)
    if value < 0 or value > 3 then
        return nil, "expected 0, 1, or 2"
    end
    self.flags.will_qos = value
    return self
end

---
---@param value boolean
---@return Connect
function Connect:set_clean_session(value)
    self.flags.clean_session = value == true
    return self
end

function Connect:reset_remaining_length()
    self.fixed_header.remaining_length = self:encoded_packet_length()
end

function Payload.new(client_id, will, username, password)
    assert(client_id, debug.traceback())
    return setmetatable({
        client_id = client_id,
        will = will,
        username = username,
        password = password,
    }, Payload)
end

function Payload.decode_with(source, flags)
    flags = flags or {}
    local ident, will, username, password
    local s, err = pcall(function()
        ident = assert(utils.decode_string(source))
        if flags.will_flag then
            will = {
                topic_name = assert(TopicName.decode(source)),
                bytes = assert(utils.decode_string(source))
            }
        end
        if flags.username then
            username = assert(utils.decode_string(source))
        end
        if flags.password then
            password = assert(utils.decode_string(source))
        end
    end)
    if not s then return nil, err end
    return Payload.new(ident, will, username, password)
end

function Payload:encode()
    local ret = utils.encode_string(self.client_id)
    if self.will then
        ret = ret .. self.will.topic_name:encode()
            .. utils.encode_string(self.will.bytes)
    end
    if self.username then
        ret = ret .. utils.encode_string(self.username)
    end
    if self.password then
        ret = ret .. utils.encode_string(self.password)
    end
    return ret
end

function Payload:encoded_length()
    local ret = 2 + #self.client_id
    if self.will then
        ret = ret + self.will.topic_name:encoded_length()
            +  2 + #self.will.bytes
    end
    if self.username then
        ret = ret +  2 + #self.username
    end
    if self.password then
        ret = ret + 2 + #self.password
    end
    return ret
end

return Connect
