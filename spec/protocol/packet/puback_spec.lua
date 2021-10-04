local PubAck = require "lumina.protocol.packet.pub_ack"
local test_utils = require "spec.test_utils"
local function round_trip_encode(v)
    local source = test_utils.generate_source(assert(v:encode_packet()))
    local back = assert(PubAck.decode_packet(source, v.fixed_header))
    assert.are.same(v, back)
end
describe("PubAck", function()
    it("round trip encoding", function()
        local v = PubAck.new(1)
        round_trip_encode(v)
    end)
    it("encoded_packet_length", function()
        local v = assert(PubAck.new(1))
        assert.are.equal(2, v:encoded_packet_length())
    end)
end)