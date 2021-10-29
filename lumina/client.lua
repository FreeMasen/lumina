local cosock = require "cosock"
local Packet = require "lumina.protocol.packet"
local ConnAckRetCode = require "lumina.protocol.packet.variable_header.connect_ret_code"
local utils = require "lumina.utils"

local Client = {}
Client.__index = Client

function Client.new(config)
    return setmetatable({
        config = config,
    }, Client)
end

function Client.connect_tcp(ip, port)
    local socket = cosock.socket.tcp()
    socket:setoption("reuseaddr", true)
    socket:connect(ip, port)
    return socket
end

function Client:connect_mqtt(ip, port, client_id)
    assert(client_id)
    if not self._sock then
        self._sock = self.connect_tcp(ip, port)
        self._source = utils.sourceify(self._sock)
    end
    local packet = assert(Packet.connect(client_id))

    packet:set_clean_session(true)
    assert(self:_send(packet))
    local conn_ack = self:_wait_for_next()
    print(conn_ack)
    assert(ConnAckRetCode.is_ret_code_accept(conn_ack.ret_code.value))
    return 1
end

function Client:subscribe(topics, callback)
    local sub = assert(Packet.subscribe(1, topics))
    self:_send(sub)
    local acks = self:_wait_for_next()
    for _, ack in pairs(acks.inner.payload.subscribes) do
        if ack.value > 2 then
            return nil, "Failed to subscribe"
        end
    end
    while true do
        print(assert(self:_wait_for_next()))
    end
end

function Client:_send(packet)
    local bytes = packet:encode()
    print("sending:", packet)
    local ttl_sent = 0
    while ttl_sent < #bytes do
        local ct, err = self._sock:send(bytes:sub(ttl_sent+1))
        if not ct then return nil, err end
        ttl_sent = ttl_sent + ct
    end
    print('sent', ttl_sent)
    return 1
end

function Client:_wait_for_next()

    local packet = assert(Packet.decode(self._source))
    print("received", packet)
    return packet
end
return Client
