local FixedHeader = require "lumina.protocol.packet.fixed_header"
local packet_protos = {
    [1] = require "lumina.protocol.packet.connect",
    [2] = require "lumina.protocol.packet.connack",
    [3] = require "lumina.protocol.packet.publish",
    [4] = require "lumina.protocol.packet.pub_ack",
    [5] = require "lumina.protocol.packet.pub_rec",
    [6] = require "lumina.protocol.packet.pub_rel",
    [7] = require "lumina.protocol.packet.pub_comp",
    [8] = require "lumina.protocol.packet.subscribe",
    [9] = require "lumina.protocol.packet.suback",
    [10] = require "lumina.protocol.packet.unsubscribe",
    [11] = require "lumina.protocol.packet.unsuback",
    [12] = require "lumina.protocol.packet.ping_req",
    [13] = require "lumina.protocol.packet.ping_res",
    [14] = require "lumina.protocol.packet.disconnect",
}

local Packet = {}
Packet.__index = Packet
Packet.__tostring = function(self)
    return require "lumina.utils".packet_string("Packet", self)
end

function Packet.from(inner)
    return setmetatable({inner = inner}, Packet)
end

function Packet._from_proto(idx, ...)
    local inner, err = packet_protos[idx].new(...)
    if not inner then return nil, err end
    return Packet.from(inner)
end

function Packet.decode(source)
    local fixed_header = assert(FixedHeader.decode(source))
    return Packet.decode_with(source, fixed_header)
end

---
---@param source function(integer):string
---@param fixed_header FixedHeader
function Packet.decode_with(source, fixed_header)
    local proto = packet_protos[fixed_header.packet_type._control_type]
    if not proto then
        return nil, string.format("Unknown packet type: %s", fixed_header)
    end
    local inner = proto.decode_packet(source, fixed_header)
    return setmetatable({inner = inner}, Packet)
end

function Packet:encode()
    assert(self.inner, debug.traceback())
    return self.inner.fixed_header:encode()..self.inner:encode_packet()
end

function Packet:encoded_length()
    return self.inner.fixed_header:encoded_length() + self.inner:encoded_packet_length()
end

-- pub const CONNECT:     u8 = 1;

function Packet.connect(client_id)
    return Packet._from_proto(1, client_id)
end
-- pub const CONNACK:     u8 = 2;

function Packet.connack(flags, ret_code)
    return Packet._from_proto(2, flags, ret_code)
end

-- pub const DISCONNECT:  u8 = 14;
function Packet.disconnect()
    return Packet._from_proto(14)
end

-- pub const PINGREQ:     u8 = 12;
function Packet.pingreq()
    return Packet._from_proto(12)
end

-- pub const PINGRESP:    u8 = 13;
function Packet.pingres()
    return Packet._from_proto(13)
end

-- pub const PUBACK:      u8 = 4;
function Packet.puback(packet_id)
    return Packet._from_proto(4, packet_id)
end


-- pub const PUBCOMP:     u8 = 7;
function Packet.pubcomp(packet_id)
    return Packet._from_proto(7, packet_id)
end

-- pub const PUBREC:      u8 = 5;
function Packet.pubrec(packet_id)
    return Packet._from_proto(5, packet_id)
end

-- pub const PUBREL:      u8 = 6;
function Packet.pubrel(packet_id)
    return Packet._from_proto(6, packet_id)
end

-- pub const PUBLISH:     u8 = 3;
function Packet.publish(topic_name, packet_id, qos, payload)
    return Packet._from_proto(3, topic_name, packet_id, qos, payload)    
end

-- pub const SUBACK:      u8 = 9;
function Packet.suback(packet_id, subscribes)
    return Packet._from_proto(9, packet_id, subscribes)
end

-- pub const SUBSCRIBE:   u8 = 8;
function Packet.subscribe(packet_id, subscribes)
    return Packet._from_proto(8, packet_id, subscribes)
    
end
-- pub const UNSUBACK:    u8 = 11;
function Packet.unsuback(packet_id)
    return Packet._from_proto(11, packet_id)
end

-- pub const UNSUBSCRIBE: u8 = 10;
function Packet.unsubscribe(packet_id, payload)
    return Packet._from_proto(10, packet_id, payload)
end

return Packet
