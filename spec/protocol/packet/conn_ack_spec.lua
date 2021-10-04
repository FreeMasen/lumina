local ConnAckFlags = require "lumina.protocol.packet.variable_header.conn_ack_flags"
local ConnAckRetCode = require "lumina.protocol.packet.variable_header.connect_ret_code"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"
local test_utils = require "spec.test_utils"
local ConnAck = require "lumina.protocol.packet.connack"


describe("ConnAck", function()
    it("round trip encoding", function()
        local flags = ConnAckFlags.new(true, true, true, 1, true, true, true)
        local ret = ConnAckRetCode.from(1)
        local fixed_header = assert(FixedHeader.from(
            PacketType.from(1, 0),
            flags:encoded_length() + ret:encoded_length()
        ))
        local v = assert(ConnAck.from(fixed_header, flags, ret))
        local source = test_utils.generate_source(v:encode_packet())
        local back = assert(ConnAck.decode_packet(source, fixed_header))
        assert.are.same(v, back)
    end)
    it("accurate length", function()
        local flags = ConnAckFlags.new(true, true, true, 1, true, true, true)
        local ret = ConnAckRetCode.from(1)
        local fixed_header = FixedHeader.from(
            PacketType.from(1, 0),
            flags:encoded_length() + ret:encoded_length()
        )
        local v = ConnAck.from(fixed_header, flags, ret)
        assert.are.equal(v:encoded_packet_length(), 2)
    end)
end)