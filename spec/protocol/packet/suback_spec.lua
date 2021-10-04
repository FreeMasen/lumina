local FixedHeader = require "lumina.protocol.packet.fixed_header"
local PacketType = require "lumina.protocol.packet.packet_type"
local test_utils = require "spec.test_utils"
local SubAck = require "lumina.protocol.packet.suback"


describe("SubAck", function()
    it("round trip encoding", function()
        local v = SubAck.new(1, {0,1,2,128})
        local source = test_utils.generate_source(
            assert(v:encode_packet()),
            "sub-ack"
        )
        local back = assert(SubAck.decode_packet(source, v.fixed_header))
        assert.are.same(v, back)
    end)
    it("accurate length", function()
        local v = SubAck.new(1, {0,1,2,128})
        assert.are.equal(6, v:encoded_packet_length())
    end)
    it("bad flags cause error #a", function()
        local v, err = SubAck.new(1, {7})
        assert(not v and err)
    end)
end)